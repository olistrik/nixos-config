{ pkgs, ... }:
{
  imports = [];

  config = {
    environment.systemPackages = with pkgs; [
      i3blocks
    ];

    environment.etc."i3blocks.conf".text = ''
      [click]
      full_text=Click me!
      command=echo "Got clicked with button $button"
      color=#F79494

      # Guess the weather hourly
      [weather]
      command=curl -Ss 'https://wttr.in?0&T&Q' | cut -c 16- | head -2 | xargs echo
      interval=3600
      color=#A4C2F4

      # Query my default IP address only on startup
      [ip]
      command=hostname -i | awk '{ print "IP:" $1 }'
      interval=once
      color=#91E78B

      # Update time every 5 seconds
      [time]
      command=date +%T
      interval=5
    '';
  };
}
