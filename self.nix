{
  overrides ? { },
  sources ? (import ./npins) // overrides,
  pkgs ? import sources.nixpkgs { },
  lib ? import ./lib.nix { inherit pkgs; },
}:
let
  self = {
    inherit
      lib
      sources
      ;
    pkgs = import ./packages.nix { inherit self; };
    modules = import ./modules.nix { inherit self; };
  };
in
self
