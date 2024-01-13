{ config, lib, pkgs, ... }: {
  # add fonts for polybar and Alacritty.
  fonts.packages = with pkgs; [
    hermit
    (unstable.nerdfonts.override { fonts = [ "Hermit" "JetBrainsMono" ]; })
  ];

  # configure alacritty
  programs.alacritty = {
    enable = true;
    brightBold = true;
    font = {
      normal.family = "JetBrainsMono NerdFont";
    };
    theme = config.system.themer.theme;
    window.opacity = "0.95";
  };
}
