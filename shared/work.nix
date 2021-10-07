# The default configuration for all systems.
# May need to be further divided in the future to allow for easier control
# of different kinds of systems.

{ config, lib, pkgs, ... }:
{
  networking.extraHosts = ''
    127.0.0.1 keycloak
    127.0.0.1 ckan
    127.0.0.1 s3
  '';

  # programs that don't need "much" configuration.
  environment.systemPackages = with pkgs; [
    # utility
    postman
    httpie

    # communications
    unstable.discord
    zoom-us
    teams

    # editors
    jetbrains.goland
    jetbrains.webstorm
    jetbrains.idea-community
    unstable.poedit

    # Docker
    docker-compose

    # JavaScript
    yarn
    nodejs
    nodePackages."@angular/cli"
    nodePackages.prettier

    # C & C++
    gcc10
    gdb
    valgrind
    binutils

    # Python
    python39

    #Web Browsers
    google-chrome
    firefox

    wakatime
  ];

  # wakatime variables
  environment.variables.WAKATIME_BIN = "${pkgs.wakatime}/bin/wakatime";

  # Docker
  virtualisation.docker.enable = true;
  users.users.kranex.extraGroups = [ "docker" ];
}

