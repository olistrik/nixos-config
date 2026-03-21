args@{
  my ? import ./my.nix args,
  ...
}:
let
  pkgs = import my.sources.nixpkgs { };
  nvf = (import my.sources.nvf).outputs;

  baseConfig =
    extraModules:
    (nvf.lib.neovimConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit my;
      };

      modules =
        with my.modules.nvf.config;
        [
          base
          keymaps
          wayland # TODO: make this opt-out.
        ]
        ++ extraModules;
    }).neovim;
in
rec {
  nvim-minimal = baseConfig [ ];
  nvim-full = baseConfig (
    with my.modules.nvf.config;
    [
      lsp
      opencode
    ]
  );
  default = nvim-full;
}
