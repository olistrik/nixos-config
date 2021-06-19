# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, secrets, ... }:

{

  # Define acounts account. Don't forget to set a password with ‘passwd’.
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

