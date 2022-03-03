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
  ];

  programs = {
    ssh = {
      startAgent = false;
    };
    gnupg = {
      package = pkgs.unstable.gnupg;
      agent = {
        enable = true;
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

