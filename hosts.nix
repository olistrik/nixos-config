args@{
  my ? import ./. args,
  ...
}:
let
  mkHosts = my.lib.mkHostsWith my;
in
mkHosts {
  thoth = { };
  hestia = { };
}
