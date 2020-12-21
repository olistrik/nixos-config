# The default configuration for all systems.
# May need to be further divided in the future to allow for easier control
# of different kinds of systems.

{ config, lib, pkgs, ... }:

let

  inherit (lib.modules) mkDefault;

in

{

  imports = [
    ./audio.nix
    ./scripts/screencapture.nix
    ./programs/zsh.nix
    ./programs/neovim.nix
    ./programs/alacritty.nix
    #./programs/jetbrains.nix
  ];

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # misc
    killall
    zip
    unzip
    neofetch
    tree

    # Net sync.
    wget
    git

    # Document viewers.
    feh
    zathura
    mplayer

    ##################
    ## develop stuff

    # General
    gnumake
    direnv
    nix-direnv

    # Docker
    docker-compose

    # JavaScript
    nodejs
    yarn

    # Ruby
    ruby

    # C & C++
    gcc10
    gdb
    valgrind
    binutils

    #Web Browser
    chromium  #
    firefox   #
  ];

  # Docker
  virtualisation.docker.enable = true;
  users.users.kranex.extraGroups = [ "docker" ];

  # Configure direnv
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
  environment.pathsToLink = [
    "share/nix-direnv"
  ];

}

