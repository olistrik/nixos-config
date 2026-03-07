{
  nixos.containers.docker =
    { pkgs, ... }:
    {
      virtualisation.docker = {
        enable = true;
        package = pkgs.docker.override { };
      };
    };
}
