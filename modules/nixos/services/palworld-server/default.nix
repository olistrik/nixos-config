# Huge thanks to @Zumorica for creating the initial module:
# https://github.com/Zumorica/GradientOS/blob/main/hosts/asiyah/palworld-server.nix
{ config
, pkgs
, lib
, ...
}:
let
  cfg = config.olistrik.services.palworld-server;
in
{
  options.olistrik.services.palworld-server = {
    enable = lib.mkEnableOption "Palworld server";

    autostart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically start the server.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8211;
      description = "The port to run the server on.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Wether to open the firewall or not";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "palworld";
      description = "The user to run the server as";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "palworld";
      description = "The group to run the server as";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    users = {
      users = lib.optionalAttrs (cfg.user == "palworld") {
        palworld = {
          isSystemUser = true;
          home = "/var/lib/palworld-server";
          createHome = true;
          homeMode = "750";
          group = cfg.group;
        };
      };

      groups = lib.optionalAttrs (cfg.group == "palworld") {
        palworld = { };
      };
    };


    # systemd.tmpfiles.rules = [
    #   "d ${user-home}/.steam 0755 ${cfg.user.name} ${cfg.user.group} - -"
    #   "L+ ${user-home}/.steam/sdk64 - - - - ${steamcmd-home}/apps/1007/linux64"
    # ];

    systemd.services.palworld-server =
      let
        palworld-server = pkgs.olistrik.palworld-server.override {
          saveDirectory = config.users.users.${cfg.user}.home;
        };
      in
      {
        path = [ pkgs.xdg-user-dirs ];

        # Manually start the server if needed, to save resources.
        wantedBy = lib.optional cfg.autostart "network-online.target";

        serviceConfig = {
          ExecStart = lib.escapeShellArgs [
            "${palworld-server}/bin/palworld-server"
            "-publicport=${toString cfg.port}"
            "-useperfthreads"

            "-NoAsyncLoadingThread"
            "-UseMultithreadForDS"
            "EpicApp=PalServer"
          ];

          Nice = "-5";
          PrivateTmp = true;
          Restart = "on-failure";
          User = cfg.group;
          WorkingDirectory = "~";
        };
      };
  };
}
