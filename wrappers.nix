{
  sources ? import ./npins,
  pkgs ? import sources.nixpkgs { },
  lib ? import ./lib.nix { inherit sources pkgs; },
  modules ? lib.importModules ./modules,
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
        self = {
          inherit sources lib modules;
        };
      };
      modules = [ { inherit pkgs; } ] ++ toList module;
    }).config.wrapper;

  mapModules = mapAttrs (_: val: evalPackage val);
  mapNamespaces = mapAttrs (_: val: mapModules val);

  wrappers = mapModules modules.wrappers.my;
in
wrappers
