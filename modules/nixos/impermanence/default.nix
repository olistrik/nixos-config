{ lib, config, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.impermanence;
in
{

  options.olistrik.impermanence = with types; {
    enable = mkOpt bool false "Whether to enable system impermanence.";
    persistentPath = mkOpt str "/persist" "The location to store persisted files.";
    zfs = mkSub "configuration options for zfs impermanence" {
      snapshots = mkOpt (listOf str) [ ] "list of snapshots to rollback on boot";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.users.mutableUsers == false;
        message = "root impermanence cannot be combined with mutableUsers.";
      }
    ];

    boot.initrd.postDeviceCommands = mkAfter (
      builtins.concatStringsSep "/n" (
        map (snapshot: "zfs rollback -r ${snapshot}") cfg.zfs.snapshots
      )
    );
  };
}
