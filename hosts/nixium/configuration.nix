# ############################
## AMD 5950X + NVIDIA 3080 ##
#############################
## Partitions:             ##
## /dev/nvme1: EFI BOOT    ##
## /dev/nvme2: ROOT        ##
#############################

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./rgb.nix

    ../../shared/personal.nix
    ../../shared/work.nix
    ../../shared/wm/i3.nix
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot.binfmt.emulatedSystems = [ "armv6l-linux" "aarch64-linux" ];

  nixpkgs.config.allowUnfree = true;

  #######################
  ## ASUS X570-E Specific

  #boot.extraModprobeConfig = ''
  #  options snd-hda-intel enable=0,1 index=-1
  #  options snd-usb-audio enable=1,0 index=-2
  #'';

  #######################
  ## AMD 5950X Specific

  #########################
  ## NVIDIA 3080 Specific

  services.xserver.videoDrivers = [ "nvidia" ];

  #######################
  ## Home/Work Specific

  # Set up refind for dual boot
  environment.systemPackages = with pkgs; [ efibootmgr refind sl ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
  };

  # While I do intend to work on this system, it is primarily a personal
  # system. Personal desktops are Alkali Metals and this one is running
  # Nixos. Nixos + Lithium = Nixium.
  networking.hostName = "nixium";

  # Make the CRG9 readable.
  services.xserver.resolutions = [{
    x = 5120;
    y = 1440;
  }];
  environment.variables.WINIT_X11_SCALE_FACTOR = "1.25";

  programs.alacritty = {
    font.size = "10.0";
    theme = config.system.themer.theme;
  };

  #################
  ## Localisation

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
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

  ############
  ## Network

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp7s0.useDHCP = true;

  # Not using these.
  networking.interfaces.enp6s0.useDHCP = false;
  networking.interfaces.wlp5s0.useDHCP = false;

  # don't stall boot for 2000 years.
  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
