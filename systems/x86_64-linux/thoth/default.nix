# Thoth is my personal laptop as it is used primarily for university work and
# provisioning my other nixos hosts.

{ lib, pkgs, inputs, ... }:
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

    virtualisation = {
      docker = enabled;
    };
  };

  # Required for ZFS.
  networking.hostId = "8177229e";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Impermanence. Get rekt python.
  olistrik.impermanence.enable = true;
  users.mutableUsers = false;
  olistrik.user.hashedPasswordFile = "/persist/secret/user.password";
  olistrik.impermanence.zfs.snapshots = [ "zroot/local/root@blank" ];
  # When I'm ready for home impermanence, I'll add "zroot/local/home@blank"

  # Enable laptop powersaving features
  services.thermald.enable = true;
  services.tlp.enable = true;
  services.upower.enable = true;

  # Enable Network Manager for WiFi.
  networking.networkmanager.enable = true;
  olistrik.user.extraGroups = [ "networkmanager" ];

  # Apparently I am in the minority of preferring wires.
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };

  # Configure audio priority (WIP: The wireplumber docs are really confusing.)
  # TODO: make this cleaner.
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

  # Enable printing service. It doesn't work very well though.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };


  # matlab is a piece of sh*t
  environment.systemPackages = with pkgs; [
    matlab
    matlab-shell
    (writeShellScriptBin "matlab-cli" ''
      (trap "" INT; ${matlab}/bin/matlab -nodesktop -nosplash $@)
    '')
    (buildFHSEnv {
      name = "matlab-auth";
      targetPkgs = ps: (inputs.nix-matlab.targetPkgs ps);
      runScript = pkgs.writeShellScript "matlab-auth" (inputs.nix-matlab.shellHooksCommon + ''
        exec $MATLAB_INSTALL_DIR/bin/glnxa64/MathWorksProductAuthorizer
      '');
    })

  ];

  # SDR stuff.
  # hardware.rtl-sdr.enable = true;
  # rtl-sdr sdrpp noaa-apt

  programs.nix-ld.enable = true;
  #### @max wut?:
  #   nix-ld.libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs;

  services.libinput.touchpad.disableWhileTyping = true;

  # NEVER CHANGE.
  system.stateVersion = "24.05"; # Did you read the comment?
}
