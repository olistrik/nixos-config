{ pkgs, ... }:
{
  imports = [];

  config = {
    environment.systemPackages = with pkgs; [
      i3blocks
    ];

    environment.etc."i3blocks.conf".text = ''
      [battery]
      command=cat /sys/class/power_supply/BAT0/capacity | awk '{print " " $1 "% "}'
      interval=5

      # Update time every 5 seconds
      [time]
      command=date +%H:%M | awk '{print "  " $1 " " }'

      interval=5
    '';
  };
}
