import std.algorithm;
import std.conv;
import std.file;
import std.stdio;

class Folder {
  const string WGDIR = "/etc/wireguard/";
  const string TEMPDIR = "/tmp/";
  const string ROOTDIR = "/root/.config/wg-keys/";

  // FIXME: change TEMPDIR~bob->ROOTDIR
  void createConfigDir() { mkdir(TEMPDIR ~ "bob"); }

  // FIXME: change TEMPDIR~bob/->WGDIR
  void createConfigFile(string name, string priv) {
    File file = File(TEMPDIR ~ "bob/" ~ name ~ ".conf", "w");
    file.writeln("[Interface]");
    file.writeln("Address = 10.0.0.1/24");
    file.writeln("ListenPort = 1337");
    file.writeln("PrivateKey = " ~ priv);
    file.writeln("SaveConfig = true");
    // TODO: change default eth0
    file.writeln("PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE");
    file.writeln("PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE");
    file.close();
  }

  // FIXME: change TEMPDIR~bob/->WGDIR
  void addUser(string fileFullPath, string name, string pub) {
    File file = File(fileFullPath, "a");
    file.writeln("");
    file.writeln("[Peer]");
    file.writeln("# " ~ name);
    file.writeln("PublicKey = " ~ pub);
    file.writeln("AllowedIPs = 10.0.0." ~ countAllowedIPs(fileFullPath).to!string ~ "/32");
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
