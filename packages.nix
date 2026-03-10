{
  sources ? import ./npins,
  pkgs ? import sources.nixpkgs { },
  lib ? import ./lib.nix { inherit sources pkgs; },
  ...
}@args:
let
  # TODO: my own packages.
  packages = { };
  wrapped = import ./wrappers.nix args;
in
packages
// {
  inherit wrapped;
}
