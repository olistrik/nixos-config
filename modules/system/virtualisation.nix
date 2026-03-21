{
  nixos.system.virtualisation =
    { lib, ... }:
    {
      virtualisation.docker = {
        enable = true;
      };

      users.users.oli.extraGroups = [ "docker" ];
    };
}
