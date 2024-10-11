import std.file;
import std.stdio;

import folder;
import key;
import shell;

void main(string[] args) {
  Shell sh = new Shell;
  Folder folder = new Folder;

  if (args.length == 3 && args[1] == "server") {
    Key key = Key(args[2]);

    folder.createConfigDir();
    writeln("ok... config folder created");

    // TODO: change TEMPDIR->ROOTDIR
    int status = sh.generateKeys(folder.TEMPDIR, key.priv, key.pub);
    if (status == 0) {
      writeln("ok... keys genreated");
      // TODO: change TEMPDIR->ROOTDIR
      folder.createConfigFile(args[2], sh.readKey(folder.TEMPDIR ~ key.priv));
      writeln("ok... config file created");
    } else {
      writefln("status error code: %d", status);
    }
  } else if (args.length == 3 && args[1] == "client") {
    Key key = Key(args[2]);
    // TODO: change TEMPDIR->ROOTDIR
    int status = sh.generateKeys(folder.TEMPDIR, key.priv, key.pub);
    if (status == 0) {
      // TODO: add new user and create config
    } else {
      writefln("status error code: %d", status);
    }
  } else {
    writeln("wrong args: wghelper [server | client] [name]");
  }
}

