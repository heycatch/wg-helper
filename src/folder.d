import std.file;
import std.stdio;

class Folder {
  const string WGDIR = "/etc/wireguard/";
  const string TEMPDIR = "/tmp/";
  const string ROOTDIR = "/root/.config/wg-keys/";

  // TODO: change TEMPDIR~bob->ROOTDIR
  void createConfigDir() { mkdir(TEMPDIR ~ "bob"); }

  // TODO: change TEMPDIR~bob/->WGDIR
  void createConfigFile(string name, string priv) {
    File file = File(TEMPDIR ~ "bob/" ~ name ~ ".conf", "w");
    file.writeln("[Interface]");
    file.writeln("Address = 10.0.0.1/24");
    file.writeln("ListenPort = 1337");
    file.writeln("PrivateKey = " ~ priv);
    file.writeln("SaveConfig = true");
    file.writeln("PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE");
    file.writeln("PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE");
    file.close();
  }
}
