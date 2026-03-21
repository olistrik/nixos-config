{
  my ? import ./my.nix { },
}:
let
  mkHosts = my.lib.mkHostsWith my;
in
mkHosts {
  thoth = { };
  hestia = { };
}
