{ config, lib, pkgs, ... }: {
  imports = [ ./programs/jetbrains.nix ];

  networking.extraHosts = ''
    127.0.0.1 db
    127.0.0.1 redis
  '';

  environment.systemPackages = with pkgs; [
    # utility
    # postman
    # httpie
    # ngrok

    # communications
    (unstable.discord.override { nss = nss_latest; })
    slack-dark
    zoom-us
    teams

    # Docker
    docker-compose

    #Web Browsers
    google-chrome
    firefox
  ];
}
