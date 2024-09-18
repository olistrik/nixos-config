{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.virtualisation.docker;
in
{
  options.olistrik.virtualisation.docker = with types;
    basicOptions "Docker" // {
      rootless = mkOpt types.bool false "Use docker in rootless mode.";
      buildx = mkOpt types.bool false "Enable buildx support.";
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
