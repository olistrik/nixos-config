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
        {
          name = "vscode-eslint";
          publisher = "dbaeumer";
          version = "2.1.10";
          sha256 = "parXZhF9qyRAlmeGItCbvPfyyQQ9WmlBKKFYQ8KIFH0=";
        }
        {
          name = "gitlens";
          publisher = "eamodio";
          version = "11.3.0";
          sha256 = "m2Zn+e6hj59SujcW5ptdrYDrc4CviZ4wyCndO2BhyF8=";
        }
        {
          name = "vscode-ts-auto-return-type";
          publisher = "ebrithil30";
          version = "1.1.0";
          sha256 ="8ydpxZtKnWdfBaS9Ln10pPB0eoic+JQ5HA+rKw+BAI8=";
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
    chrome
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

