# Huge thanks to @jakehamilton for creating the module I based this on.
# https://github.com/jakehamilton/config/blob/main/modules/nixos/services/palworld/default.nix

# Huge thanks to @Zumorica for creating the initial module:
# https://github.com/Zumorica/GradientOS/blob/main/hosts/asiyah/palworld-server.nix
{ config
, pkgs
, lib
, ...
}:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.services.palworld-server;
in
{
  options.olistrik.services.palworld-server = with lib.types; {
    enable = mkEnableOption "Palworld server";

    autostart = mkOpt bool true
      "Automatically start the server.";

    autorestart = mkOpt bool true
      "Automatically restart the server at 2am.";

    port = mkOpt port 8211
      "The port to run the server on.";

    openFirewall = mkOpt bool true
      "Wether to open the firewall or not.";

    user = mkOpt str "palworld"
      "The user to run the server as.";

    group = mkOpt str "palworld"
      "The group to run the server as.";
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

    # restart nightly because memory leaks.
    systemd.timers.palworld-server-nightly-restart = mkIf cfg.autorestart {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 02:00:00";
        AccuracySec = "10min";
      };
    };
    systemd.services.palworld-server-nightly-restart = mkIf cfg.autorestart {
      serviceConfig = {
        ExecStart = "${pkgs.systemd}/bin/systemctl restart palworld-server.service";
        Type = "oneshot";
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
