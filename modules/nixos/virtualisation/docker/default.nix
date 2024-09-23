{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.virtualisation.docker;
in
{
  options.olistrik.virtualisation.docker = with types; {
    enable = mkEnableOption "docker";
    rootless = mkEnableOption "rootless mode";
    buildx = mkEnableOption "buildx support";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.docker-compose ];

    virtualisation.docker = {
      enable = true;
      package = mkIf cfg.buildx (pkgs.docker.override (args: { buildxSupport = true; }));
      rootless = mkIf cfg.rootless {
        enable = true;
        setSocketVariable = true;
      };
    };

    olistrik.user.extraGroups = mkIf (! cfg.rootless) [ "docker" ];
  };
}
