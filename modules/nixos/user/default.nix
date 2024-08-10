{ lib, config, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.user;
  authorizedKeys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMcvHSxN1mFGgB6r19eHIqGKvhNOwddvVe43NwhKHmWzAAAABHNzaDo= oli@yubikey"
  ];
in
{
  options.olistrik.user = with types; {
    enable = mkOpt bool false "Whether to enable my user settings";
    name = mkOpt str "oli" "The name of the standard account";
		hashedPasswordFile = mkOpt (nullOr str) null "A file containing the users hashed password, useful for impermanence";
    extraGroups = mkOpt (listOf str) [ ] "Any extra groups the default account should have";
    authorizedKeys = mkOpt (listOf str) [ ] "";
  };

  config.users.users.${cfg.name} = {
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
      "plugdev"
      "osboxes"
      "adbusers"
      "lxd"
      "openvpn"
    ] ++ cfg.extraGroups;

    openssh.authorizedKeys.keys = authorizedKeys;
  };
}
