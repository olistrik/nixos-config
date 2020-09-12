{ config, lib, pkgs, symlinkJoin, makeWrapper, ... }:

with lib;

let

  cfge = config.environment;
  cfg = config.programs.eclipse;

in {
  options = {
    programs.eclipse.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        enable or disable eclipse.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (import ./eclipse.nix)
    ];
  };
}

