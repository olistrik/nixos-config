{config, pkgs, ...}:

{
  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;

      extraPackages = with pkgs; [
        dmenu
        i3lock
        i3status
      ];

      configFile = pkgs.writeText "i3-config" (builtins.readFile ../../dots/i3.config);
    };

  };
}
