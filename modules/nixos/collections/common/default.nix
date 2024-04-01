{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.collections.common;
in
{
  options.olistrik.collections.common = with types; {
    enable = mkOpt bool true "Whether to install common programs and configurations.";
  };
  config = mkIf cfg.enable {
    olistrik = {
      user = enabled;
      programs = {
        neovim = enabled;
        zsh = enabled;
      };
      tools = {
        direnv = enabled;
      };
    };

    boot.supportedFilesystems = [ "ntfs" ];

    programs.ssh = {
      startAgent = true;
      extraConfig = ''
        Host gitlab.com
        UpdateHostKeys no
      '';
    };

    # TODO: extract to own module with nixwarden secrets.
    services.tailscale.enable = true;

    environment.systemPackages = with pkgs; with olistrik; [
      # Fetchers
      git
      wget
      curl

      # Monitoring
      htop
      ncdu

      # Packaging
      zip
      unzip
      unrar

      # misc
      killall
      tree
      parallel
      ripgrep

      # maintainance tools
      gen-package-lock
      mk-installer
    ];
  };
}
