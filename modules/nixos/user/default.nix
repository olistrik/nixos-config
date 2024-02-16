{ lib, config, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.user;
in
{
  options.olistrik.user = with types; {
    name = mkOpt str "oli" "The name of the standard account";
    initialPassword = mkOpt str "password" "The initial password for the standard account";
    extraGroups = mkOpt (listOf str) [ ] "Any extra groups the default account should have";
  };

  config.users.users.${cfg.name} = {
    inherit (cfg) name initialPassword;

    isNormalUser = true;
    extraGroups = [
      "wheel"
      "audio"
      "sound"
      "video"
      "input"
      "tty"

      # TODO: Move to a better place
      "dialout"
      "plugdev"
      "osboxes"
      "adbusers"
      "lxd"
      "openvpn"
    ] ++ cfg.extraGroups;
  };
}
