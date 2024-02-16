{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.tools.direnv;
in
{
  options.olistrik.tools.direnv = basicOptions "direnv";
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ direnv nix-direnv ];

    # Configure direnv, also requires `eval ${direnv hook zsh)` in zsh.
    # TODO move direnv to it's own module and make it set that hook somehow.
    nix.settings = {
      keep-outputs = true;
      keep-derivations = true;
    };

    environment.pathsToLink = [ "/share/nix-direnv" ];
  };
}
