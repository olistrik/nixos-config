# requires nix2vim
{ pkgs }:
pkgs.neovimBuilder {
  enableViAlias = true;
  enableVimAlias = true;

  imports = [
    ./modules/ayu.nix
    ./modules/lualine.nix
    ./modules/telescope.nix
    ./modules/treesitter.nix
    ./modules/nvim-tree.nix

  ];

  plugins = with pkgs.vimPlugins; [ ];

}
