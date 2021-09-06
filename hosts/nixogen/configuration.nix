# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ../../shared/personal.nix
      ../../shared/work.nix
    ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config.allowUnfree = true;
  
  ##################
  ## Work specific

  # Work devices are "Other non metals" and this one is running Nixos.
  # Nixos + Nitrogen = Nixogen.
  networking.hostName = "nixogen";

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      # Use Systemd-boot. Grub really doesn't like LUKS.
      systemd-boot.enable = true;
      # Change the EFI mount point to "/boot/efi"
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
    ## Mark /dev/nvme2 as luks.
    initrd.luks.devices = {
      root = {
       device = "/dev/disk/by-uuid/affa3eb4-7e3f-4a0e-9c7e-bdcd46777c51";
       preLVM = true;
      };
    };
  };
  
  ####################
  ## Laptop Specific

  # Enable laptop touchpad.
  services.xserver.libinput.mouse = {
      accelSpeed = "-0.75";
  };

  # Enables wireless support via wpa_supplicant.
  networking.wireless = {
    enable = true;
    interfaces = [ "wlp60s0" ];
  };

  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp60s0.useDHCP = true;

  services.autorandr.enable = true;

  # environment.variables.WINIT_X11_SCALE_FACTOR = "1.25";

  #################
  ## Localisation

  # Locale
  time.timeZone = "Europe/Amsterdam";

  # Terminal keymap and font.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  ## set X11 localisation
  services.xserver = {
    layout = "us";
    xkbOptions = "eurosign:5";
  };

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

