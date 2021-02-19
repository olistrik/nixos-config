# The default configuration for all systems.
# May need to be further divided in the future to allow for easier control
# of different kinds of systems.

{ config, lib, pkgs, ... }:

let

  inherit (lib.modules) mkDefault;

in

{

  imports = [
    ./audio.nix # explicitly disable that plague called pulseaudio
    ./scripts/screencapture.nix # for screenshot etc

    # install programs with my configurations
    ./programs/zsh.nix
    ./programs/neovim.nix
    ./programs/alacritty.nix
  ];

  # not sure why I need this. Jetbrains stuff?
  nixpkgs.config.allowUnfree = true;

  # programs that don't need "much" configuration.
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

    # Image manipulation.
    gimp

    ##################
    ## develop stuff

    # General
    gnumake
    direnv
    nix-direnv
    vscode

    # Docker
    docker-compose

    # Java
    jre8

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

  # Configure direnv, also requires `eval ${direnv hook zsh)` in zsh.
  # TODO move direnv to it's own module and make it set that hook somehow.
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
  environment.pathsToLink = [
    "share/nix-direnv"
  ];
}

