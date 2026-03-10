{
  sources ? import ./npins,
  pkgs ? import sources.nixpkgs { },
  lib ? import ./lib.nix { inherit sources pkgs; },
  modules ? lib.importModules ./modules,
}:
let
  self = {
    inherit
      sources
      lib
      modules
      ;
    pkgs = import ./packages.nix { inherit self; };
  };
in
self
