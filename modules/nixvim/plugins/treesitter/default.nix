{ config, pkgs, lib, ... }:
let
  allGrammars = config.plugins.treesitter.package.passthru.allGrammars;
in
with lib;
with lib.olistrik;
with lib.olistrik.nixvim;
mkPlugin "treesitter" {
  inherit config;
  plugins = {
    treesitter = {
      enable = true;
      indent = true;
      grammarPackages = with pkgs.olistrik; allGrammars ++ [
        tree-sitter-go-template
      ];
    };

    ts-autotag = {
      enable = true;
    };

    nvim-autopairs = {
      settings = {
        check_ts = true;
      };
    };

    treesitter-textobjects = {
      enable = true;

      select = {
        enable = true;
        lookahead = true;
        keymaps = {
          "af" = "@function.outer";
          "if" = "@function.inner";

          "ac" = "@conditional.outer";
          "ic" = "@conditional.inner";

          "iC" = "@class.inner";
          "aC" = "@class.outer";

          "iB" = "@block.inner";
          "aB" = "@block.outer";

          # argument (p is already paragraph)
          "ia" = "@parameter.inner";
          "aa" = "@parameter.outer";

          # invocation
          "ii" = "@call.inner";
          "ai" = "@call.outer";
        };
      };
    };
  };
}
