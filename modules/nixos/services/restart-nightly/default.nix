{ config
, pkgs
, lib
, ...
}:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.services.restart-nightly;
in
{
  options.olistrik.services.restart-nightly = {
    enable = mkEnableOption "restart-nightly service";
  };

  config = lib.mkIf cfg.enable {
    systemd.timers."restart-nightly@" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 02:00:00";
        AccuracySec = "10min";
      };
    };
    systemd.services."restart-nightly@" = {
      serviceConfig = {
        ExecStart = "${pkgs.systemd}/bin/systemctl restart %i.service";
        Type = "oneshot";
      };
    };
  };
}
