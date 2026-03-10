{
  self ? import ./self.nix { },
  sources ? self.sources,
  pkgs ? import sources.nixpkgs { },
  nvf ? (import sources.nvf).outputs,
}:
let

  baseConfig =
    extraModules:
    (nvf.lib.neovimConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        _ = self;
      };

      modules =
        with self.modules.nvf.config;
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
    with self.modules.nvf.config;
    [
      lsp
      opencode
    ]
  );
  default = nvim-full;
}
