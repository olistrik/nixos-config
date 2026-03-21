{
  self ? import ./self.nix { },
}:
let
  mkHosts = self.lib.mkHostsWith self;
in
mkHosts {
  thoth = { };
  hestia = { };
}
