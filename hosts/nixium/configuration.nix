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

  # Set up refind for dual boot
  environment.systemPackages = with pkgs; [
    efibootmgr
    refind
  ];

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
        set $left  "DP-4"
        set $right "HDMI-0"

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
        workspace $ws1 output $left
        workspace $ws2 output $right
        workspace $ws3 output $left
        workspace $ws4 output $right
        workspace $ws5 output $left
        workspace $ws6 output $right
        workspace $ws7 output $left
        workspace $ws8 output $right

        # switch workspace
        bindsym $mod+1 workspace number $ws1
        bindsym $mod+2 workspace number $ws2
        bindsym $mod+3 workspace number $ws3
        bindsym $mod+4 workspace number $ws4
        bindsym $mod+5 workspace number $ws5
        bindsym $mod+6 workspace number $ws6
        bindsym $mod+7 workspace number $ws7
        bindsym $mod+8 workspace number $ws8

        # send container to workspace
        bindsym $mod+Shift+exclam     move container to workspace number $ws1
        bindsym $mod+Shift+at         move container to workspace number $ws2
        bindsym $mod+Shift+numbersign move container to workspace number $ws3
        bindsym $mod+Shift+dollar     move container to workspace number $ws4
        bindsym $mod+Shift+percent    move container to workspace number $ws5
        bindsym $mod+Shift+asciicirum move container to workspace number $ws6
        bindsym $mod+Shift+ampersand  move container to workspace number $ws7
        bindsym $mod+Shift+asterisk   move container to workspace number $ws8
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

  #################################
  ## Super Ultra wide boiii
  services.xserver.resolutions = [{ x = 5120; y = 1440; }];

  environment.variables.WINIT_X11_SCALE_FACTOR = "1.25";

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
  system.stateVersion = "20.09"; # Did you read the comment?

}

