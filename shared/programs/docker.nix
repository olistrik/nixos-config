{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [ docker-compose ];

  # Docker
  virtualisation = {
    docker = {
      enable = true;
      package = (pkgs.docker.override (args: { buildxSupport = true; }));
    };
  };

  users.users.oli.extraGroups = [ "docker" ];
}
