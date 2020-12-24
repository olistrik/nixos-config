{config, lib, pkgs, ...}:

with lib;

let
  themer = config.system.themer;
  chucknorris = pkgs.writeScriptBin "chucknorris" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.wget}/bin/wget http://api.icndb.com/jokes/random -qO- | ${pkgs.jshon}/bin/jshon -e value -e joke -u | fold -s'';
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
