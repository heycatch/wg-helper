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
    if (keys == 0) {
      writeln("ok... keys genreated");
      // FIXME: change config~temp/->WGDIR
      folder.createServerConfigFile(
        config ~ "temp/", args[2], sh.readKey(config ~ "server/" ~ key.priv));
      writeln("ok... config file created");
    } else {
      writefln("generate keys error code: %d", keys);
    }
  } else if (args.length == 3 && args[1] == "client") {
    Key key = Key(args[2]);

    int keys = sh.generateKeys(config, key.priv, key.pub);
    if (keys == 0) {
      // FIXME: change config~temp->WGDIR; config~temp->WGDIR
      folder.addUser(
        config ~ "temp/" ~ sh.lsDir(config ~ "temp"),
        args[2], sh.readKey(config ~ key.pub));
      writefln("ok... %s added", args[2]);
      // TODO: client configuration for windows/linux/android/iphone,
      // save to /tmp/ and make a notification

      writeln("restart the server now? y/n");
      string input = readln();
      if (input[0..$-1] == "y") {
        // FIXME: change sh.lsDir(config~temp)->WGDIR
        int server = sh.restartServer(sh.lsDir(config ~ "temp")[0..$-5]);
        if (server == 0) {
          writeln("ok... server restarted");
        } else {
          writeln("restart server error code: %d", server);
        }
      } else {
        writeln("don't forget to restart the server");
      }
    } else {
      writefln("generate keys error code: %d", keys);
    }
  } else {
    writeln("wrong args: wghelper [server | client] [name]");
  }
}

