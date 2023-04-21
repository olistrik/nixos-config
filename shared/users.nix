{ config, pkgs, ... }: {
  # Define acounts account.
  users.users = {
    kranex = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "audio"
        "sound"
        "video"
        "input"
        "tty"
        "dialout"
        "plugdev"
        "osboxes"
        "adbusers"
        "lxd"
        "openvpn"
      ];
    };
  };
}
