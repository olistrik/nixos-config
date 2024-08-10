{ lib, ... }:
with lib;
with lib.olistrik;
{
  imports = [
    ./hardware-configuration.nix
    ./disko-configuration.nix
    ./persistence-configuration.nix
  ];

  # Shared configurations.
  olistrik = {
    collections = {
      personal = enabled;
      workstation = enabled;
    };

    wayland = {
      niri = enabled;
      ags = enabled;
    };
  };

  # Required for ZFS.
  networking.hostId = "8177229e";

  # Impermanence. Get rekt python.
  olistrik.impermanence.enable = true;
  users.mutableUsers = false;
  olistrik.user.hashedPasswordFile = "/persist/secret/user.password";
  olistrik.impermanence.zfs.snapshots = [ "zroot/local/root@blank" ];
  # When I'm ready for home impermanence, I'll add "zroot/local/home@blank"

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable wireless.
  hardware.bluetooth.enable = true;
  networking.networkmanager.enable = true;
  olistrik.user.extraGroups = [ "networkmanager" ];

  # Enable laptop powersaving features
  services.thermald.enable = true;
  services.tlp.enable = true;

  # NEVER CHANGE.
  system.stateVersion = "24.05"; # Did you read the comment?
}

# Legacy from nixogen:

#### Yubikey management stuff:
# environment.systemPackages = with pkgs; [ yubikey-manager ];
# services.udev.packages = [ pkgs.yubikey-personalization ];
# services.pcscd.enable = true;

#### Angular bullshit probably:
# boot.loader.kernel.sysctl = { "fs.inotify.max_user_watches" = "1048576"; };

#### wut?:
# hardware.opengl = {
#   enable = true;
#   driSupport = true;
#   extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];
# };

#### wut?:
# hardware.bluetooth.settings.General = {
#   Enable = "Source,Sink,Media,Socket";
#   Disable = "Headset";
# };

#### sus:
# # Enable laptop touchpad.
# services.libinput.mouse = { accelSpeed = "-0.85"; };


#### docker bullshit?:
# networking.useDHCP = false;
# networking.interfaces.enp0s31f6.useDHCP = true;
# networking.interfaces.wlp60s0.useDHCP = true;

#### @max wut?:
# programs.nix-ld = {
#   enable = true;
#   libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs;
# };
