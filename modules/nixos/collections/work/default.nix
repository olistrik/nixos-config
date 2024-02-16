{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.collections.work;
  cakeproof-slack = with pkgs; writeShellScriptBin "slack" ''
    	  if ${ksshaskpass}/bin/ksshaskpass | sudo -k -S true; then
    		  exec ${slack}/bin/slack
    	  else
    		  exec xdg-open "https://www.youtube.com/watch?v=qdrs3gr_GAs"
    	  fi
    	'';
in
{
  options.olistrik.collections.work = basicOptions "work programs";

  config = mkIf cfg.enable {
    networking.extraHosts = ''
      127.0.0.1 db
      127.0.0.1 redis
      127.0.0.1 minio
      127.0.0.1 lago-api
    '';

    environment.systemPackages = with pkgs; with jetbrains; [
      # communications
      zoom-us
      cakeproof-slack

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
