import std.file;
import std.stdio;

import folder;
import info;
import key;
import shell;

void main(string[] args) {
  Shell sh = new Shell;
  Folder folder = new Folder;

  string config = sh.configPath();

  if (args.length == 3 && args[1] == "server") {
    Key key = Key(args[2]);

    folder.createConfigDir(config);
    writeln("ok... config folder created");
    folder.createConfigDir(config ~ "server");
    writeln("ok... server folder created");

    int keys = sh.generateKeys(config ~ "server", key.priv, key.pub);
    assert(keys == 0, "key generation error");
    writeln("ok... keys genreated");

    folder.createServerConfigFile(
      folder.WGDIR, args[2],
      sh.readKey(config ~ "server/" ~ key.priv),
      sh.getEthInterface());
    writeln("ok... config file created");

    int startService = sh.startSystemctl(sh.lsDir(folder.WGDIR)[0..$-5]);
    assert(startService == 0, "failed to start the service");
    writeln("ok... service started");
  } else if (args.length == 3 && args[1] == "client") {
    Key key = Key(args[2]);

    int keys = sh.generateKeys(config, key.priv, key.pub);
    assert(keys == 0, "key generation error");
    writeln("ok... keys genreated");

    int count = folder.countAllowedIPs(folder.WGDIR ~ sh.lsDir(folder.WGDIR));

    folder.addUser(
      folder.WGDIR ~ sh.lsDir(folder.WGDIR),
      args[2], sh.readKey(config ~ key.pub), count);
    writefln("ok... %s added", args[2]);
    folder.createUserConfigFile(
      Info.SERVERLOCATION, count, sh.readKey(config ~ key.priv),
      sh.readKey(config ~ "server/publickey.*"), sh.getIpAddress(), Info.SERVERPORT);
    writefln("ok... %s.conf saved in %s", Info.SERVERLOCATION, folder.TEMPDIR);

    int server = sh.restartServer(sh.lsDir(folder.WGDIR)[0..$-5]);
    assert(server == 0, "failed to restart the server");
    writeln("ok... server restarted");
  } else {
    writeln(sh.lsDir(folder.WGDIR)[0..$-5]);
    writeln("wrong args: wghelper [server | client] [name]");
  }
}

