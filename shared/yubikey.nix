{ config, lib, pkgs, ... }:
let

in {
  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubico-pam
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
        pinentryFlavor = "curses";
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

