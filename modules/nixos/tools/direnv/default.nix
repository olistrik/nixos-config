{ lib, config, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.tools.direnv;
in
{
  options.olistrik.tools.direnv = {
    enable = mkEnableOption "direnv";
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
    programs.direnv.enable = true;

    olistrik.programs.zsh = mkIf cfg.shellHooks.zsh.enable {
      extraConfig = ''eval "$(${config.programs.direnv.package}/bin/direnv hook zsh)"'';
    };
  };
}

