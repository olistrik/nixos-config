{ pkgs, dsl, ... }:
with dsl; {
  plugins = with pkgs.vimPlugins; [ neovim-ayu ];

  lua = ''
    require('ayu').setup({
      mirage = "true",
      overrides = {}
    })

    require('ayu').colorscheme()
  '';
}
