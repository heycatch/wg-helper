import std.format;
import std.process;
import std.string;

class Shell {
  string configPath() {
    string name = executeShell("whoami").output.strip();
    if (name == "root") {
      return "/root/.config/wg-keys/";
    }
    return "/home/" ~ name ~ "/.config/wg-keys/";
  }

  int generateKeys(string path, string priv, string pub) {
    string command = format(
      "wg genkey | tee %s/%s | wg pubkey | tee %s/%s",
      path, priv, path, pub);
    return executeShell(command).status;
  }

  string readKey(string key) {
    string command = format("cat %s", key);
    return executeShell(command).output.strip();
  }

  string lsDir(string path) {
    string command = format("ls %s", path);
    return executeShell(command).output.strip();
  }

  int restartServer(string name) {
    string command = format("wg-quick down %s && wg-quick up %s", name, name);
    return executeShell(command).status;
  }

  string getEthInterface() {
    string command = executeShell("ip addr | grep '2: '").output.strip();
    string res = "";

    for (int i = 3; i < command.split("").length; i++) {
      if (command[i] == ':') break;
      res ~= command[i];
    }

    return res;
  }
}
