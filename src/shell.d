import std.format;
import std.process;
import std.string;

class Shell {
  string configPath() {
    string name = executeShell("whoami").output.strip();
    string path = name == "root" ? "/root/.config/wg-keys/" : "/home/" ~ name ~ "/.config/wg-keys/";
    return path;
  }

  int generateKeys(string path, string priv, string pub) {
    return executeShell(format("wg genkey | tee %s/%s | wg pubkey | tee %s/%s", path, priv, path, pub)).status;
  }

  string readKey(string key) {
    return executeShell(format("cat %s", key)).output.strip();
  }

  string lsDir(string path) {
    return executeShell(format("ls %s", path)).output.strip();
  }

  int restartServer(string name) {
    return executeShell(format("wg-quick down %s && wg-quick up %s", name, name)).status;
  }

  int startSystemctl(string name) {
    return executeShell(format("systemctl enable wg-quick@%s && systemctl start wg-quick@%s", name, name)).status;
  }

  string getEthInterface() {
    string eth = "";
    string command = executeShell("ip addr | grep '2: '").output.strip();

    for (int i = 3; i < command.split("").length; i++) {
      if (command[i] == ':') break;
      eth ~= command[i];
    }

    return eth;
  }

  string getIpAddress() {
    return executeShell("curl -s ifconfig.me").output.strip();
  }
}
