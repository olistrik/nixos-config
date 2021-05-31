# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

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
    ./hardware-configuration.nix
    ../../shared/themer.nix
    ../../shared/users.nix
    ../../shared/work.nix
    ../../shared/wm/bspwm.nix
#    ../../shared/programs/R.nix
    ../../shared/programs/Pandoc.nix
    ../../shared/ssh.nix
    ./firewall.nix

  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  environment.systemPackages = with pkgs; [
    refind
    efibootmgr
  ];

  ###########################
  ## Boot

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      efiSupport = true;
      device = "nodev";
    };
  };

  ##############################
  ## networking

  networking.dhcpcd.enable = false;
  networking.interfaces.eno1.ipv4.addresses = [ {
    address = "192.168.1.10";
    prefixLength = 24;
  } ];

  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "1.1.1.1" ];

  networking.hostName = "nixbidium"; # Define your hostname.

  #################################
  ## Programs

  # configure eclipse
  programs.eclipse.enable = true;

  ################
  ## Theming WIP

  system.themer = {
    theme = import ../../shared/themes/ayu-mirage.nix;
    wm = {
      gaps = {
        inner = 5;
        outer = -4;
      };
    };
  };

  programs.alacritty = {
    font.size = "10.0";
    theme = config.system.themer.theme;
  };

  #services.xserver.displayManager.sddm.autoLogin = {
  #  enable = true;
  #  user = "root";
  #};

}
