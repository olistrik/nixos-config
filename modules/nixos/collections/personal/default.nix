# These are programs and their configs that I want on personal systems but are
# not needed on servers etc.
{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.collections.personal;
in
{
  options.olistrik.collections.personal = with types; {
    enable = mkEnableOption "personal configuration";
  };

  config = mkIf cfg.enable {
    # TODO: Every single item is graphical. Perhaps I should rethink my collections.
    environment.systemPackages = with pkgs;
      [
        # media
        spotify
        feh
        mplayer
        zathura
        discord
        signal-desktop

        # editing
        gimp
        inkscape
        obsidian
        vscode

        # browsers
        firefox # Fuck you Google.
        thunderbird
      ];
  };
}
