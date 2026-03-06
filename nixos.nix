let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { config.allowUnfree = true; };
  unstable = import sources.unstable { config.allowUnfree = true; };
  nixosSystem = import "${sources.nixpkgs}/nixos/lib/eval-config.nix";

  mkHost =
    hostVars:
    nixosSystem {
      specialArgs = {
        self = {
          inherit sources hostVars;
          # packages = import ./packages.nix { inherit pkgs sources; };
        };
      };
      modules = [ ./modules/hosts/${hostVars.hostname}/configuration.nix ];
    };

in
{
  thoth = mkHost {
    hostname = "thoth";
    # configDirectory = "";
  };
}
