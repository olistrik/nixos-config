# requires nix2vim
{ pkgs }:
pkgs.neovimBuilder {
  enableViAlias = true;
  enableVimAlias = true;

  imports = [ ./modules/ayu.nix ./modules/lualine.nix ./modules/telescope.nix ];

  plugins = with pkgs.vimPlugins;
    [

    ];
}
