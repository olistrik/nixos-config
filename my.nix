{
  overrides ? { },
  sources ? (import ./npins) // overrides,
  pkgs ? import sources.nixpkgs { },
  lib ? import ./lib.nix { inherit pkgs; },
}:
let
  my = {
    inherit
      lib
      sources
      ;
    pkgs = import ./packages.nix { inherit my; };
    modules = import ./modules.nix { inherit my; };
  };
in
my
