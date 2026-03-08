{
  # TODO: think up a better name.
  nixos.collections.personal =
    { pkgs, ... }:
    {
      # TODO: Every single item is graphical. Perhaps I should rethink my collections.
      environment.systemPackages = with pkgs; [
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
