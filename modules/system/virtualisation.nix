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
    };
}
