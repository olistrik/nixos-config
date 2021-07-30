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
    ./themer.nix
    ./users.nix

    # install programs with my configurations
    ./programs/zsh.nix
    ./programs/neovim
  ];

  # Every pc needs this.
  programs = {
    ssh = {
      startAgent = false;
      extraConfig = ''
      Host gitlab.com
        UpdateHostKeys no
      '';
    };
  };


  # programs that don't need "much" configuration.
  environment.systemPackages = with pkgs; [
    # General
    git
    wget

    # misc
    killall
    zip
    unzip
    neofetch
    tree

    # devenv
    gnumake
    direnv
    nix-direnv

    # C & C++
    gcc10
    gdb
    valgrind
    binutils
  ];

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

