{config, lib, pkgs, ...}:

let
  inherit (lib.modules) mkDefault;
in {
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
    };
  };
}
