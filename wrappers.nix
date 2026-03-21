args@{
  my ? import ./my.nix args,
  ...
}:
let
  pkgs = import my.sources.nixpkgs { };
  nix-wrapper-modules = import (my.sources.nix-wrapper-modules) {
    inherit (my.sources) nixpkgs;
    inherit pkgs;
  };

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
