{ config
, lib
, ...
}:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.services.valheim-server;
in
{
  options.olistrik.services.valheim-server = with lib.types; {
    enable = mkEnableOption "Valheim server";
    serverName = mkOpt str "valheim.olii.nl"
      "The name of the server in the server list.";
    worldName = mkOpt str "Midgard"
      "The name of the world in the server list.";
    password = mkOpt str "12345"
      "The password for the server.";
    openFirewall = mkOpt bool true
      "Whether to open the firewall or not.";
    extraOptions = mkOpt (attrsOf anything) { }
      "Extra options for upstream valheim server module.";
  };

  config = lib.mkIf cfg.enable {
    services.valheim = {
      inherit (cfg) enable serverName worldName password openFirewall;
    } // cfg.extraOptions;
  };
}
