{
  secrets = builtins.fromJSON (builtins.readFile ./secrets.json);
}
