{ config, pkgs, ... }:
let
  plugins = config.programs.nixvim.plugins;
in
{
  programs.nixvim.plugins = {
    treesitter = {
      indent = true;
      grammarPackages = with pkgs.olistrik.tree-sitter-grammars;
        plugins.treesitter.package.passthru.allGrammars ++
        [
          tree-sitter-go-template
        ];
    };


    ts-autotag = {
      enable = plugins.treesitter.enable;
    };
    nvim-autopairs = {
      checkTs = plugins.treesitter.enable;
    };

    treesitter-textobjects = {
      enable = plugins.treesitter.enable;

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
