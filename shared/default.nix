# The default configuration for all systems.
# May need to be further divided in the future to allow for easier control
# of different kinds of systems.

{ config, lib, pkgs, ... }:

let inherit (lib.modules) mkDefault;

in {

  imports = [
    ./cachix

    # install programs with my configurations
    ./programs/zsh.nix
    ./programs/neovim
    ./programs/direnv.nix
    ./programs/tailscale.nix
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config.allowUnfree = true;
  boot.supportedFilesystems = [ "ntfs" ];

  nix.settings.auto-optimise-store = true;

  # Every pc needs this.
  programs = {
    ssh = {
      extraConfig = ''
        Host gitlab.com
          UpdateHostKeys no
      '';
    };
  };

  # programs that don't need "much" configuration.
  environment.systemPackages = with pkgs; [
    # Fetchers
    git
    wget
    curl

    # Build Tools
    gnumake

    # Monitoring
    htop

    # Packaging
    zip
    unzip

    # misc
    killall
    neofetch
    tree
    parallel

    # USB utils
    ventoy-bin
  ];
}
