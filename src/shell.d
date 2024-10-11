import std.format;
import std.process;
import std.string;

class Shell {
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
}
