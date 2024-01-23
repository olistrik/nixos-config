{ config, pkgs, lib, ... }:
let
  plugins = config.programs.nixvim.plugins;
in
{
  programs.nixvim.plugins = lib.mkIf plugins.treesitter.enable {
    treesitter = {
      indent = true;
      grammarPackages = with pkgs.olistrik.tree-sitter-grammars;
        plugins.treesitter.package.passthru.allGrammars ++
        [
          tree-sitter-go-template
        ];
    };


    ts-autotag = {
      enable = true;
    };

    nvim-autopairs = {
      extraOptions = {
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
