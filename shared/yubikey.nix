{ config, lib, pkgs, ... }:
let

in {
  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubico-pam
  ];


  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  security.pam.yubico = {
    enable = true;
    mode = "challenge-response";
  };
}

