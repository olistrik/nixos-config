# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-custom, ... }:

#let eclipse_unwrapped = (pkgs.eclipses.eclipseWithPlugins {
#       eclipse = pkgs.eclipses.eclipse-platform;
#       jvmArgs = ["-Xmx2048m"];
#       plugins = with pkgs.eclipses.plugins; [
#           vrapper
#       ];
#     });
#in
{
  imports = [
    ./nixpkgs-custom
    ./hardware-configuration.nix
    ../../shared/efi.nix
    ../../shared/default.nix
#    ../../shared/programs/R.nix
 #   ../../shared/programs/TeX.nix
    ./firewall.nix

  ];


#  nix = {
#    package = pkgs.nixUnstable;
#    extraOptions = ''
#      experimental-features = nix-command flakes
#    '';
#  };

  environment.systemPackages = with pkgs.qt5; [
    qtbase
    qtquickcontrols
    qtgraphicaleffects
    pkgs-custom.hello
  ];

  #pkgs.(writeScriptBin "eclipse" ''
  #    #!${pkgs.stdenv.shell}
  #    exec GTK_THEME=Raleigh ${pkgs.eclipses.eclipseWithPlugins}/bin/eclipse
  #  '');

  networking.dhcpcd.enable = false;
  networking.interfaces.eno1.ipv4.addresses = [ {
    address = "192.168.1.10";
    prefixLength = 24;
  } ];

  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "1.1.1.1" ];

  networking.hostName = "nixbidium"; # Define your hostname.

  # configure bspwm
  programs.bspwm.enable = true;
  services.xserver.displayManager.defaultSession = "none+bspwm";
  services.xserver.displayManager.sddm.theme = "${(pkgs.fetchFromGitHub {
    owner = "MarianArlt";
    repo = "sddm-chili";
    rev = "0.1.5";
    sha256 = "036fxsa7m8ymmp3p40z671z163y6fcsa9a641lrxdrw225ssq5f3";
  })}";

  # configure alacritty
  programs.alacritty = {
    enable = true;
    brightBold = true;
    theme = import ../../themes/ayu-mirage.nix;
  };

  # configure eclipse
  programs.eclipse.enable = true;

  #services.xserver.displayManager.sddm.autoLogin = {
  #  enable = true;
  #  user = "root";
  #};

}
