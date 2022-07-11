{ pkgs, dsl, ... }:
with dsl; {
  plugins = with pkgs.vimPlugins; [ neovim-ayu ];

  # setup.ayu = {
  #   mirage = true;
  #   overrides = { };
  # };

  lua = ''
    require('ayu').setup({
      mirage = true;
      overrides = { };
    })
    require('ayu').colorscheme()
  '';
}
