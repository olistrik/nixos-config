{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.collections.common;
in
{
  options.olistrik.collections.common = {
    enable = mkEnableOption "common configuration" // { default = true; };
  };
  config = mkIf cfg.enable {
    olistrik = {
      user = enabled;
      programs = {
        neovim = enabled;
        zsh = enabled;
        zoxide = enabled;
        tmux = enabled;
      };
      tools = {
        direnv = enabled;
      };
    };

    boot.supportedFilesystems = [ "ntfs" ];

    programs.ssh = {
      startAgent = true;
      enableAskPassword = true;
      askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
      extraConfig = ''
        AddKeysToAgent yes

        Host gitlab.com
          UpdateHostKeys no
      '';
    };

    # Disable the sudoers lecture. I've read it.
    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';

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
      tmux

      # maintainance tools
      gen-package-lock
    ];
  };
}
