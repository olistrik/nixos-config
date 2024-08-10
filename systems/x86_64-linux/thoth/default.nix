{ inputs, lib, pkgs, ... }:
with lib;
with lib.olistrik;
{
  imports =
    [
      # Provided here for now. Later it'll be global.
      inputs.disko.nixosModules.default

      ./hardware-configuration.nix
      ./disko-configuration.nix
      ./persistence-configuration.nix
    ];

  networking.hostName = "thoth"; # Define your hostname.
	networking.hostId = "8177229e";

  olistrik = {
    collections = {
      personal = enabled;
      workstation = enabled;
      work = enabled; # WARN: Remove. I'm a student now. We don't do work.
    };
    wayland = {
      niri = enabled;
      ags = enabled;
    };
  };

	# impermanence wipes out password changes, and binding /etc/shadow doesn't seem to fix that.
	olistrik.user.hashedPasswordFile = "/persist/secret/user.password";
	users.mutableUsers = false;

  # Impermanence. Get rekt python.
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r zroot/local/root@blank
  '';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi"; 
  # boot.kernel.sysctl = { "fs.inotify.max_user_watches" = "1048576"; };

  # Enable networking
  networking.networkmanager.enable = true;
  olistrik.user.extraGroups = [ "networkmanager" ];

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "euro";
  };

  # NEVER CHANGE.
  system.stateVersion = "24.05"; # Did you read the comment?
}
