{ config, lib, pkgs, ... }: {
  imports = [
    ../programs/waybar
  ];

  programs.hyprland.enable = true;
  security.pam.services.swaylock = { };
  # FROM SWAY:
  # extraSessionCommands = ''
  #		export MOZ_ENABLE_WAYLAND=1
  #		export _JAVA_AWT_WM_NONREPARENTING=1
  #		systemctl --user import-environment
  # '';

  environment.systemPackages = with pkgs; [
    hyprpaper
    swaylock
    swayidle
    wofi
    xwayland
    way-displays
    grim
    jq
    slurp
    wl-clipboard
    playerctl
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
