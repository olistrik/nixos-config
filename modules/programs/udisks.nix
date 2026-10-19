{
  nixos.programs.udisks =
    { pkgs, ... }:
    let
      # udiskie only reads ~/.config/udiskie, so the config is passed explicitly.
      udiskieConfig = pkgs.writeText "udiskie-config.yml" ''
        notifications:
          # seconds before a popup disappears on its own
          timeout: 3
      '';
    in
    {
      # Lets an active local session mount and unmount removable drives through
      # polkit, e.g. `udisksctl mount -b /dev/sdb1`, without root or the disk group.
      services.udisks2.enable = true;

      environment.systemPackages = [ pkgs.udiskie ];

      # Mounts removable drives as they are plugged in. It only talks to udisks
      # over D-Bus, so it doesn't need a graphical session or a tray.
      systemd.user.services.udiskie = {
        description = "Automount removable drives";
        wantedBy = [ "default.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.udiskie}/bin/udiskie --config ${udiskieConfig} --automount --no-tray";
          Restart = "on-failure";
        };
      };
    };
}
