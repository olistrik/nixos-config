{ config, pkgs, secrets, ... }:

{
  # Define acounts account.
  users = {
    mutableUsers = false;
    users = {
      kranex = {
        isNormalUser = true;
        extraGroups = [ "wheel" "audio" "sound" "video" "input" "tty" "dialout"
      "osboxes"]; # Enable ‘sudo’ for the user.
        hashedPassword = secrets.users.kranex.hashedPassword;
      };
      root = {
        hashedPassword = secrets.users.root.hashedPassword;
      };
    };
  };

}

