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

    # Net sync.
    wget
    git

    # Document viewers.
    feh
    zathura
    mplayer

    #bspwm stuff
    polybar
    dmenu
    sxhkd
    compton
    neofetch

    #Web Browser
    chromium
    firefox
  ];

}

