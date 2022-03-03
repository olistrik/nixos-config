{ config, lib, pkgs, ... }:
let

in {
  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubico-pam
  ];

  programs.ssh = {
    startAgent = true;
  };

  security.pam = {
    yubico = {
      enable = false;
      mode = "challenge-response";
    };
  };
}

