args@{
  my ? import ./my.nix args,
  ...
}:
let
  mkHosts = my.lib.mkHostsWith my;
in
mkHosts {
  thoth = { };
  hestia = { };
}
