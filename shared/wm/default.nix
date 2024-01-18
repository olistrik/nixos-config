{ pkgs, ... }: {
  imports = [
    ./hyprland
    ./greetd
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    xdgOpenUsePortal = true;
  };
}
