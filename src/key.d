struct Key {
  string pub;
  string priv;

  this(string name) {
    this.pub = "publickey." ~ name;
    this.priv = "privatekey." ~ name;
  }
}
