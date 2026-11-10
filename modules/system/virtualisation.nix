{
  nixos.system.virtualisation =
    { ... }:
    {
      # Rootless Docker runs as the invoking user, avoiding the rootful daemon
      # and its root-equivalent `docker` group.
      virtualisation.docker = {
        enable = false;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };

      # The rootless daemon's user unit has no CA bundle in its environment,
      # so registry pulls fail TLS verification.
      systemd.user.services.docker.environment.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";

      virtualisation.libvirtd.enable = true;

      users.users.oli.extraGroups = [ "libvirtd" ];

      environment.persistence."/persist".directories = [
        "/var/lib/docker"
        "/var/lib/libvirt"
      ];
    };
}
