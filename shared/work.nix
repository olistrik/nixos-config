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
    unstable.commitizen

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
    (vscode-with-extensions.override {
      vscodeExtensions = (with unstable.vscode-extensions; [
        ms-vsliveshare.vsliveshare
        vscodevim.vim
        eamodio.gitlens
        dbaeumer.vscode-eslint
      ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "ruby";
          publisher = "rebornix";
          version = "0.28.1";
          sha256 = "HAUdv+2T+neJ5aCGiQ37pCO6x6r57HIUnLm4apg9L50=";
        }
        {
          name = "vscode-ruby";
          publisher = "wingrunr21";
          version = "0.28.0";
          sha256 = "H3f1+c31x+lgCzhgTb0uLg9Bdn3pZyJGPPwfpCYrS70=";
        }
      ];
    })

    # Docker
    docker-compose

    # Java
    jre8

    # JavaScript
    nodejs
    yarn

    # Ruby
    ruby.devEnv
    sqlite
    libpcap
    postgresql
    libxml2
    libxslt
    pkg-config
    bundix

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

