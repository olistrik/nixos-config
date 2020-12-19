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
    ./screencapture.nix
    ./programs/zsh.nix
    ./programs/neovim.nix
    #./programs/jetbrains.nix
  ];

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # misc
    killall
    zip
    unzip
    neofetch

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

    ######################
    ## Move somewhere else

    #bspwm stuff
    polybar  #
    dmenu    #
    sxhkd    #
    picom    #

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
  environment.pathToLink = [
    "share/nix-direnv"
  ];

}

