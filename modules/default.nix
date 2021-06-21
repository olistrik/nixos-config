{ config, lib, pkgs, ...}:

{
  imports = [
    ./programs/alacritty
    ./programs/bspwm
    ./programs/eclipse
  ];
}
