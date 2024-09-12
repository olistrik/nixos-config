{ ... }: {
  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      # system
      "/etc/NetworkManager/system-connections"
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/bluetooth"

      # services
      "/var/lib/tailscale"
    ];
    files = [
      # machine-id
      "/etc/machine-id"
    ];
  };
}
