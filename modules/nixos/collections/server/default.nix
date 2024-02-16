{ lib, config, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.collections.server;
in
{
  options.olistrik.collections.server = basicOptions "server configuration";

  config = mkIf cfg.enable {
    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };
}
