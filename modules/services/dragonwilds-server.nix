{
  nixos.services.dragonwilds-server =
    { config, lib, ... }:
    let
      cfg = config.services.dragonwilds-server;
    in
    {
      options.services.dragonwilds-server = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable the RuneScape: Dragonwilds dedicated server.";
        };

        image = lib.mkOption {
          type = lib.types.str;
          default = "ghcr.io/runescape/rsdw-dedicated";
          description = "Container image to run.";
        };

        imageTag = lib.mkOption {
          type = lib.types.str;
          default = "latest";
          description = "Tag of the container image to run.";
        };

        stateDir = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/dragonwilds-server";
          description = ''
            Host directory bind-mounted onto the container's `/home/steam/rsdw-dedicated`.
            Holds the downloaded server files, world saves and generated config.
          '';
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 7777;
          description = "UDP port for the server process to bind to.";
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to open the UDP port in the firewall.";
        };

        serverName = lib.mkOption {
          type = lib.types.str;
          default = "rsdw-container";
          description = "Name of the server.";
        };

        worldName = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = ''
            Visible name of the server in the Worlds browser.
            Left unset, the server picks a random name on each start.
          '';
        };

        ownerId = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = ''
            The EOS Online ID of the server owner, found in-game under Settings.
            Required, either here or via `environmentFiles` (as `RSDW_OWNER_ID`).
          '';
        };

        password = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = ''
            Server password. Left unset, the server generates a random one on
            each start (visible in the container logs).
          '';
        };

        admins = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
          example = [ "72057602627862526" ];
          description = "EOS Online IDs to grant server admin.";
        };

        adminPassword = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = ''
            Server admin password. Left unset, the server generates a random
            one on each start (visible in the container logs).
          '';
        };

        additionalArgs = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Additional CLI arguments passed to RSDragonwildsServer.sh.";
        };

        autoStopOnUpdate = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Stop the server when a new Steam build is detected, relying on the
            container's restart policy to bring it back up on the new version.
          '';
        };

        validateFiles = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether steamcmd should validate (and redownload) game files on startup.";
        };

        debug = lib.mkOption {
          type = lib.types.ints.between 0 3;
          default = 0;
          description = "Log verbosity (0=none, 1=steamcmd, 2=rsdw, 3=all).";
        };

        environmentFiles = lib.mkOption {
          type = with lib.types; listOf path;
          default = [ ];
          description = ''
            Files in systemd EnvironmentFile format providing secret environment
            variables (e.g. `RSDW_OWNER_ID`, `RSDW_PASSWORD`, `RSDW_ADMIN_PASSWORD`)
            to the container, without putting them in the Nix store.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        virtualisation.podman.enable = true;
        virtualisation.oci-containers.backend = "podman";

        # The image runs as a baked-in uid/gid 1000 ("steam") with no userns
        # remap under rootful podman, so the bind mount must be owned by 1000:1000
        # for the container to write to it.
        systemd.tmpfiles.rules = [
          "d ${cfg.stateDir} 0750 1000 1000 -"
        ];

        virtualisation.oci-containers.containers.dragonwilds-server = {
          image = "${cfg.image}:${cfg.imageTag}";
          autoStart = true;
          ports = [ "${toString cfg.port}:${toString cfg.port}/udp" ];
          volumes = [ "${cfg.stateDir}:/home/steam/rsdw-dedicated" ];
          environmentFiles = cfg.environmentFiles;
          environment = lib.filterAttrs (_: v: v != null) {
            RSDW_PORT = toString cfg.port;
            RSDW_SERVER_NAME = cfg.serverName;
            RSDW_WORLD_NAME = cfg.worldName;
            RSDW_OWNER_ID = cfg.ownerId;
            RSDW_PASSWORD = cfg.password;
            RSDW_ADMIN_PASSWORD = cfg.adminPassword;
            RSDW_ADMINS = if cfg.admins != [ ] then lib.concatStringsSep "," cfg.admins else null;
            RSDW_ADDITIONAL_ARGS = if cfg.additionalArgs != "" then cfg.additionalArgs else null;
            RSDW_AUTO_STOP_ON_UPDATE = if cfg.autoStopOnUpdate then "true" else null;
            STEAMAPPVALIDATE = if cfg.validateFiles then "1" else null;
            DEBUG = if cfg.debug != 0 then toString cfg.debug else null;
          };
        };

        networking.firewall = lib.mkIf cfg.openFirewall {
          allowedUDPPorts = [ cfg.port ];
        };

        assertions = [
          {
            assertion = cfg.ownerId != null || cfg.environmentFiles != [ ];
            message = "services.dragonwilds-server: set services.dragonwilds-server.ownerId, or provide RSDW_OWNER_ID via environmentFiles.";
          }
        ];
      };
    };
}
