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
    ./programs/direnv.nix
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
    gnumake

    # misc
    killall
    zip
    unzip
    neofetch
    tree

    # C & C++
    gcc10
    gdb
    valgrind
    binutils
  ];
}
