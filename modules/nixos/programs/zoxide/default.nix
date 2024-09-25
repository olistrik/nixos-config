{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.programs.zoxide;
in
{
  options.olistrik.programs.zoxide = {
    enable = mkEnableOption "zoxide";
    package = mkOpt types.package pkgs.zoxide "zoxide package";
    # TODO: lib this for all shells, etc.
    shellHooks = mkSub "config for shell hooks" {
      zsh = mkSub "config for zsh" {
        enable = mkEnableOption "zsh hook" // {
          default = config.olistrik.programs.zsh.enable;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # TODO: work out how to drop the global install of zoxide;
    # the init script assumes it's on the path.
    environment.systemPackages = [ cfg.package ];

    olistrik.programs.zsh = mkIf cfg.shellHooks.zsh.enable {
      extraConfig = ''eval "$(${cfg.package}/bin/zoxide init zsh)"'';
    };
  };
}
