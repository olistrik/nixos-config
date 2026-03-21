{ pkgs, ... }:
let
  nixosSystem = import "${pkgs.path}/nixos/lib/eval-config.nix";

  mkHost =
    my: hostname: hostVars:
    nixosSystem {
      specialArgs = {
        my = my // {
          inherit hostVars;
        };
      };
      modules = with my.modules.nixos; [
        hosts.all # meta package for anything that should be on all hosts.
        hosts.${hostname}
        ({
          networking.hostName = "${hostname}";
        })
      ];
    };

  mkHostsWith = my: builtins.mapAttrs (mkHost my);
in
{
  inherit mkHost mkHostsWith;
}
