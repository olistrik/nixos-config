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
    # passwordEnvFile = ...;
    openFirewall = mkOpt bool true
      "Whether to open the firewall or not.";
    noGraphics = mkOpt bool true
      "If enabled, disables initalization of the graphics device.";
    public = mkOpt bool false
      "If enabled, shows the server on the steam and community lists.";
    extraOptions = mkOpt (attrsOf anything) { }
      "Extra options for upstream valheim server module.";
  };

  config = lib.mkIf cfg.enable {
    services.valheim = {
      inherit (cfg)
        enable
        serverName
        worldName
        password
        openFirewall
        noGraphics
        public
        ;
    } // cfg.extraOptions;
  };
}
