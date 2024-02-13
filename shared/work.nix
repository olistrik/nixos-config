{ config, lib, pkgs, ... }:
let
  cakeproof-slack = with pkgs; writeShellScriptBin "slack" ''
    	  if ${ksshaskpass}/bin/ksshaskpass | sudo -k -S true; then
    		  exec ${slack}/bin/slack
    	  else
    		  exec xdg-open "https://www.youtube.com/watch?v=qdrs3gr_GAs"
    	  fi
    	'';
in
{
  imports = [ ./programs/jetbrains.nix ];

  networking.extraHosts = ''
    127.0.0.1 db
    127.0.0.1 redis
    127.0.0.1 minio
    127.0.0.1 lago-api
  '';

  environment.systemPackages = with pkgs; [
    # communications
    (unstable.discord.override { nss = nss_latest; })
    zoom-us
    cakeproof-slack

    # The worst software in the world
    vscode
    firefox
    bruno
  ];
}
