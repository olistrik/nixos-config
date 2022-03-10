{ config, lib, pkgs, ... }:
let

in {
  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubikey-manager
    yubico-pam
    pinentry-curses
    pinentry-qt
    pinentry-gtk2
    # x11-ssh-askpass
  ];

  programs = {
    ssh = {
      startAgent = true;
    };
    gnupg = {
      package = pkgs.unstable.gnupg;
      agent = {
        enable = false;
        enableSSHSupport = true;
        pinentryFlavor = "gtk2";
      };
    };
  };

  security.pam = {
    yubico = {
      enable = false;
      mode = "challenge-response";
    };
  };
}

