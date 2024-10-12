import std.algorithm;
import std.conv;
import std.file;
import std.stdio;

class Folder {
  const string WGDIR = "/etc/wireguard/";
  const string TEMPDIR = "/tmp/";

  void createConfigDir(string path) { mkdir(path); }

  void createServerConfigFile(string path, string name, string priv, string ethInterface) {
    File file = File(path ~ name ~ ".conf", "w");
    file.writeln("[Interface]");
    file.writeln("Address = 10.0.0.1/24");
    file.writeln("ListenPort = 1337");
    file.writeln("PrivateKey = " ~ priv); // server private key
    file.writeln("SaveConfig = true");
    file.writeln(
      "PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o " ~
      ethInterface ~ " -j MASQUERADE");
    file.writeln(
      "PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o " ~
      ethInterface ~ " -j MASQUERADE");
    file.close();
  }

  void addUser(string fileFullPath, string name, string pub) {
    File file = File(fileFullPath, "a");
    file.writeln("");
    file.writeln("[Peer]");
    file.writeln("# " ~ name);
    file.writeln("PublicKey = " ~ pub); // client public key
    file.writeln("AllowedIPs = 10.0.0." ~ countAllowedIPs(fileFullPath).to!string ~ "/32");
    file.close();
  }

  void createUserConfigFile(
      string name, string fileFullPath, string priv, string pub, string ipaddr, string port) {
    File file = File(TEMPDIR ~ name ~ ".conf", "w");
    file.writeln("[Interface]");
    file.writeln("AllowedIPs = 10.0.0." ~ (countAllowedIPs(fileFullPath)-1).to!string ~ "/32");
    file.writeln("PrivateKey = " ~ priv); // client private key
    file.writeln("DNS = 8.8.8.8");
    file.writeln("");
    file.writeln("[Peer]");
    file.writeln("PublicKey = " ~ pub); // server public key
    file.writeln("Endpoint = " ~ ipaddr ~ port); // server ip address
    file.writeln("AllowedIPs = 0.0.0.0/0");
    file.writeln("PersistentKeepalive = 20");
    file.close();
  }

  int countAllowedIPs(string fileFullPath) {
    int count = 2;

    File file = File(fileFullPath, "r");
    while (!file.eof) {
      string line = file.readln();
      if (line[0..min(line.length, 10)] == "AllowedIPs") {
        count++;
      }
    }
    file.close();

    return count;
  }
}
