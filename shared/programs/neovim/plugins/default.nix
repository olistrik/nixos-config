{ ... }: {
  imports = [
    ./colorscheme.nix
    ./lualine.nix
    ./telescope.nix
    ./treesitter.nix
    ./lsp.nix
    # easy align
    ./gitblame.nix
  ];
}
