# Thoth is my personal laptop as it is used primarily for university work and
# provisioning my other nixos hosts.

{ lib, pkgs, ... }:
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

    virtualisation = {
      docker = enabled;
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

  # Enable printing service
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Configure audio priority
  # headphones ? bluetooth > HDMI > Speaker 
  services.pipewire.wireplumber.extraConfig."10-sink-priority" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          {
            "node.name" = "~alsa_output.*";
            "device.profile.description" = "Speaker + Headphones";
            # With / Without headphones?
          }
        ];
        actions = {
          update-props = {
            "priority.driver" = "1000";
            "priority.session" = "1000";
          };
        };
      }
      {
        matches = [
          {
            "node.name" = "~alsa_output.*";
            "device.profile.description" = "HDMI / DisplayPort 1 Output";
          }
        ];
        actions = {
          update-props = {
            "priority.driver" = "500";
            "priority.session" = "500";
          };
        };
      }
      # bluetooth? monitor.bluez.rules
    ];
  };

  # matlab is a piece of sh*t
  environment.systemPackages = with pkgs; [ matlab ];

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
