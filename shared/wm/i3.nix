{config, pkgs, ...}:

{
  services.xserver = {

    enable = true;
    package = pkgs.i3-gaps;

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;

      extraPackages = with pkgs; {
        dmenu
        i3lock
        i3status
      };

      #config = pkgs.writeFile "i3-config" ''
      #
      #'';
    };
  };
}
