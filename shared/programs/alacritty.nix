{config, lib, pkgs, ...}:

{
  # add fonts for polybar and Alacritty.
  fonts.fonts = with pkgs; [
    hermit
    (unstable.nerdfonts.override { fonts = ["Hermit" "JetBrainsMono"]; })
  ];

  # configure alacritty
  programs.alacritty = {
    enable = true;
    brightBold = true;
    font = {
      normal.family = "JetBrainsMono NerdFont";
      size = "8.0";
    };
    theme = lib.mkDefault import ../../shared/themes/ayu-mirage.nix;
  };
}
