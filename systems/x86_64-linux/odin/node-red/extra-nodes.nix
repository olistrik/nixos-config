{ pkgs, lib, config, ... }:
let
  extra-nodes = pkgs.symlinkJoin {
    name = "red-node_extra-nodes";
    paths = with pkgs.olistrik; [
      node-red-contrib-zigbee2mqtt
      node-red-contrib-toggle
      node-red-contrib-wiz-local-control
      flowfuse-node-red-dashboard
      node-red-contrib-esphome
    ];
  };
in
lib.mkIf config.services.node-red.enable {
  systemd.tmpfiles.rules = [

    "L+ ${config.services.node-red.userDir}/node_modules 0755 ${config.services.node-red.user} ${config.services.node-red.group} - ${extra-nodes}/lib/node_modules"
  ];
}
