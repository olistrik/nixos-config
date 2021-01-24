#############################
## AMD 5950X + NVIDIA 3080 ##
#############################
## Partitions:             ##
## /dev/nvme1: EFI BOOT    ##
## /dev/nvme2: ROOT        ##
#############################

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../shared/themer.nix
      ../../shared/users.nix
      ../../shared/work.nix
      ../../shared/wm/i3.nix
    ];

  nix = {
    package=pkgs.nixFlakes;
    extraOptions=''
      experimental-features = nix-command flakes
    '';
  };


  #######################
  ## AMD 5950X Specific

  #########################
  ## NVIDIA 3080 Specific

  services.xserver.videoDrivers = [ "nvidia" ];

  #######################
  ## Home/Work Specific


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

    windowManager.i3 = {
      workspaces = ''
        # Set workspace names
        set $ws1 "1"
        set $ws2 "2"
        set $ws3 "3"
        set $ws4 "4"
        set $ws5 "5"
        set $ws6 "6"
        set $ws7 "7"
        set $ws8 "8"

        # Put workspaces on correct screens
        workspace $ws1 output right
        workspace $ws2 output left
        workspace $ws3 output right
        workspace $ws4 output left
        workspace $ws5 output right
        workspace $ws6 output left
        workspace $ws7 output right
        workspace $ws8 output left
      '';
    };
  };

  ############
  ## Network

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp6s0.useDHCP = true;
  networking.interfaces.enp7s0.useDHCP = true;
  networking.interfaces.wlp5s0.useDHCP = true;

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
    font.size = "8.0";
    theme = config.system.themer.theme;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

