{ inputs, lib, nixvim, ... }:
with lib;
with lib.olistrik;
let
  modules = inputs.self.nixvimModules;
in
nixvim.makeNixvimWithModule {
  module = {
    imports = attrValues modules;
    olistrik = {
      common = enabled;
      git = enabled;
      lualine = enabled;
      telescope = enabled;
      treesitter = enabled;
      codecompanion = enabled;
      lsp = enabled;
    };
  };
}
