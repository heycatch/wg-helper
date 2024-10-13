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
    // FIXME: delete temp folder after all tests
    folder.createConfigDir(config ~ "temp");

    int keys = sh.generateKeys(config ~ "server", key.priv, key.pub);
    assert(keys == 0, "key generation error");
    writeln("ok... keys genreated");

    // FIXME: change config~temp/->WGDIR
    folder.createServerConfigFile(
      config ~ "temp/", args[2],
      sh.readKey(config ~ "server/" ~ key.priv),
      sh.getEthInterface());
    writeln("ok... config file created");
  } else if (args.length == 3 && args[1] == "client") {
    Key key = Key(args[2]);

    int keys = sh.generateKeys(config, key.priv, key.pub);
    assert(keys == 0, "key generation error");
    writeln("ok... keys genreated");

    // FIXME: change config~temp->WGDIR; config~temp->WGDIR
    folder.addUser(
      config ~ "temp/" ~ sh.lsDir(config ~ "temp"),
      args[2], sh.readKey(config ~ key.pub));
    writefln("ok... %s added", args[2]);
    folder.createUserConfigFile(
      // FIXME: change config~temp/->WGDIR; config~temp->WGDIR
      Info.SERVERLOCATION, config ~ "temp/" ~ sh.lsDir(config ~ "temp"),
      sh.readKey(config ~ key.priv),
      sh.readKey(config ~ "server/publickey.*"), sh.getIpAddress(), Info.SERVERPORT);
    writefln("ok... %s.conf saved in %s", Info.SERVERLOCATION, folder.TEMPDIR);

    writeln("restart the server now? y/n");
    string input = readln();
    if (input[0..$-1] == "y") {
      // FIXME: change sh.lsDir(config~temp)->WGDIR
      int server = sh.restartServer(sh.lsDir(config ~ "temp")[0..$-5]);
      assert(server == 0, "error when trying to restart the server");
      writeln("ok... server restarted");
    } else {
      writeln("don't forget to restart the server");
    }
  } else {
    writeln("wrong args: wghelper [server | client] [name]");
  }
}

