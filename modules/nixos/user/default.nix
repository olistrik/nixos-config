{ lib, config, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.user;
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIL0q7NgpGYIG6vQqzJTD64jUASuDWxw7DNKsrw+j3G/ oli@nixogen" ];
in
{
  options.olistrik.user = with types; {
    enable = mkOpt bool false "Whether to enable my user settings";
    name = mkOpt str "oli" "The name of the standard account";
    initialPassword = mkOpt str "password" "The initial password for the standard account";
    extraGroups = mkOpt (listOf str) [ ] "Any extra groups the default account should have";
    authorizedKeys = mkOpt (listOf str) [] "";
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
    
    openssh.authorizedKeys.keys = authorizedKeys;
  };
}
