{
  my ? import ./my.nix { },
  sources ? my.sources,
  pkgs ? import sources.nixpkgs { },
  nvf ? (import sources.nvf).outputs,
}:
let

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
