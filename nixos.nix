let
  sources = import ./npins;

  # sources;
  pkgs = import sources.nixpkgs { config.allowUnfree = true; };
  unstable = import sources.unstable { config.allowUnfree = true; };
  nixosSystem = import "${sources.nixpkgs}/nixos/lib/eval-config.nix";

  # custom lib;
  lib = import ./lib { inherit (pkgs) lib; };
  # module attrset is three deep <class>.<namespace>.<module>;
  modules = lib.importSharded ./modules 3;

  mkHost =
    hostname: # todo; infer from attr.
    hostVars:
    nixosSystem {
      specialArgs = {
        self = {
          inherit
            sources
            hostVars
            lib
            modules
            ;
          # packages = import ./packages.nix { inherit pkgs sources; };
        };
      };
      modules = with modules.nixos; [ hosts.${hostname} ];
    };
in
{
  thoth = mkHost "thoth" { };
}
