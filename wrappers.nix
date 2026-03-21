{
  my ? import ./my.nix { },
  sources ? my.sources,
  pkgs ? import sources.nixpkgs { },
  nix-wrapper-modules ? import (sources.nix-wrapper-modules) {
    inherit (sources) nixpkgs;
    inherit pkgs;
  },
}:
let
  inherit (pkgs.lib) toList mapAttrs;
  inherit (nix-wrapper-modules.lib) evalModules;

  evalPackage =
    module:
    (evalModules {
      specialArgs = {
        inherit my;
      };
      modules = [ { inherit pkgs; } ] ++ toList module;
    }).config.wrapper;

  mapModules = mapAttrs (_: val: evalPackage val);
  mapNamespaces = mapAttrs (_: val: mapModules val);

  wrappers = mapModules my.modules.wrappers.config;
in
wrappers
