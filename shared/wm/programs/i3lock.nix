{config, lib, pkgs, ...}:

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
        chucknorris
        jshon
        wget
      ];

      systemd.services.suspendLock = {
        description = "lock on suspend";
        wantedBy = [ "sleep.target" ];
        before = sleep.target;
        serviceConfig = {
          Environment= "DISPLAY=:0";
          ExecStart = "${pkgs.xautolock} -locknow";
        };
      };

      services.xserver = {
        xautolock = {
          enable = true;
          time = 5;
          locker = "${pkgs.i3lock-fancy}/bin/i3lock-fancy --nofork -t 'locked' -f 'JetBrains-Mono-Regular-Nerd-Font-Complete'";
          nowlocker = "${pkgs.i3lock-fancy}/bin/i3lock-fancy --nofork -t 'locked' -f 'JetBrains-Mono-Regular-Nerd-Font-Complete'";
        };
      };
    };
  }
