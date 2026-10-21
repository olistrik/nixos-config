{
  nixos.hosts.hestia =
    { pkgs, ... }:
    {
      environment.persistence."/persist".directories = [
        # The Thread network dataset (credentials) lives here; losing it means re-commissioning every device.
        "/var/lib/thread"
        {
          # DynamicUser: systemd keeps the state under /var/lib/private and symlinks it.
          directory = "/var/lib/private/matter-server";
          mode = "0700";
        }
      ];

      # Impermanence creates this as the parent of the bind mount above with mode 0755,
      # and systemd refuses to use a StateDirectory under it unless it is 0700.
      systemd.tmpfiles.rules = [ "d /var/lib/private 0700 root root -" ];

      # The tmpfiles rule only runs at boot; impermanence recreates the parent at 0755 on a
      # switch, so also fix the mode right before the service sets up its state directory.
      systemd.services.matter-server-private-dir = {
        description = "Restrict /var/lib/private for matter-server";
        before = [ "matter-server.service" ];
        requiredBy = [ "matter-server.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.coreutils}/bin/chmod 0700 /var/lib/private";
        };
      };

      services = {
        openthread-border-router = {
          enable = true;
          backboneInterfaces = [ "enp3s0" ];
          # XIAO ESP32-C6 running the ot_rcp firmware over its USB Serial/JTAG port (see knockr-rcp).
          radio.url = "spinel+hdlc+uart:///dev/serial/by-id/usb-Espressif_USB_JTAG_serial_debug_unit_7C:2C:67:64:A5:4C-if00?uart-baudrate=460800";
          web.enable = true;
        };

        matter-server.enable = true;
      };
    };
}
