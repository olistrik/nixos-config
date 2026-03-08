{ self, ... }:
let
  nixosSystem = import "${self.sources.nixpkgs}/nixos/lib/eval-config.nix";

  mkHost =
    self: hostname: hostVars:
    nixosSystem {
      specialArgs = {
        self = self // {
          inherit hostVars;
        };
      };
      modules = with self.modules.nixos; [
        hosts.all # meta package for anything that should be on all hosts.
        hosts.${hostname}
        ({
          networking.hostName = "${hostname}";
        })
      ];
    };

  mkHostsWith = self: builtins.mapAttrs (mkHost self);
in
{
  inherit mkHost mkHostsWith;
}
