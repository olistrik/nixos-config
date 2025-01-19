{ lib, config, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.user;
in
{
  options.olistrik.user = with types; {
    enable = mkOpt bool false "Whether to enable my user settings";
    name = mkOpt str "oli" "The name of the standard account";
    hashedPasswordFile = mkOpt (nullOr str) null "A file containing the users hashed password, useful for impermanence";
    extraGroups = mkOpt (listOf str) [ ] "Any extra groups the default account should have";
    authorizedKeys = mkOpt (listOf str) [ ] "";
  };


  config = {
    nix.settings.trusted-users = [ cfg.name ];
    users.users.${cfg.name} = {
      inherit (cfg) name hashedPasswordFile;

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
        "osboxes"
        "adbusers"
        "lxd"
        "openvpn"
        "plugdev"
      ] ++ cfg.extraGroups;

      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };
  };
}
