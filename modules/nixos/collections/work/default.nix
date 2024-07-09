{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.collections.work;
in
{
  options.olistrik.collections.work = basicOptions "work programs";

  config = mkIf cfg.enable {
    networking.extraHosts = ''
      127.0.0.1 db
      127.0.0.1 redis
      127.0.0.1 clickhouse
      127.0.0.1 minio
      127.0.0.1 lago-api
    '';

    environment.systemPackages = with pkgs; with jetbrains; [
      # communications
      zoom-us
      slack

      # Inferior build tools
      docker-compose

      # The worst software in the world
      vscode
      firefox
      bruno
      goland
      webstorm
    ];

    # Docker
    virtualisation = {
      docker = {
        enable = true;
        package = (pkgs.docker.override (args: { buildxSupport = true; }));
      };
    };
    olistrik.user.extraGroups = [ "docker" ];
  };
}
