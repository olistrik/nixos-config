{ config, lib, pkgs, ... }:

with lib;

let
  themer = config.system.themer;
in
{
  imports = [
  ];

  config = {
    environment.systemPackages = with pkgs; [
      i3lock-fancy
    ];

    services.xserver = {
      xautolock = {
        enable = true;
        time = 5;
        extraOptions = [ "-detectsleep" "-lockaftersleep" ];
        locker = "${pkgs.i3lock-fancy}/bin/i3lock-fancy --nofork -t 'locked' -f 'JetBrains-Mono-Regular-Nerd-Font-Complete'";
        nowlocker = "${pkgs.i3lock-fancy}/bin/i3lock-fancy --nofork -t 'locked' -f 'JetBrains-Mono-Regular-Nerd-Font-Complete'";
      };
    };
  };
}
