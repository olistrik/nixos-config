# The default configuration for all systems.
# May need to be further divided in the future to allow for easier control
# of different kinds of systems.

{ config, lib, pkgs, ... }:

let inherit (lib.modules) mkDefault;

in {

  imports = [
    ./audio.nix # explicitly disable that plague called pulseaudio
    ./themer.nix
    ./users.nix

    # install programs with my configurations
    ./programs/zsh.nix
    ./programs/neovim
    ./programs/direnv.nix
  ];

  nix.autoOptimiseStore = true;

  # Every pc needs this.
  programs = {
    ssh = {
      extraConfig = ''
        Host gitlab.com
          UpdateHostKeys no
      '';
    };
  };

  programs.steam.enable = true;

  # programs that don't need "much" configuration.
  environment.systemPackages = with pkgs; [
    # General
    git
    kranex.git-graph
    kranex.git-igitt
    wget
    gnumake

    #coms
    signal-desktop

    # misc
    killall
    zip
    unzip
    neofetch
    tree
    parallel

    # C & C++
    gcc10
    gdb
    valgrind
    binutils

    # USB utils
    ventoy-bin

    cachix
  ];
}
