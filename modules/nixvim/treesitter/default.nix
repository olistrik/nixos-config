{ config, pkgs, lib, ... }:
let
  allGrammars = config.plugins.treesitter.package.passthru.allGrammars;
in
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.treesitter;
in
{
  options.olistrik.treesitter = {
    enable = mkEnableOption "treesitter config";
  };
  config = mkIf cfg.enable {

    # TODO: move to some glsl package.
    filetype =
      let
        extensionsToAttrs = exts: ft: builtins.listToAttrs
          (map (ext: { name = ext; value = ft; }) exts);
      in
      {
        extension = extensionsToAttrs [ "vert" "tes" "tesc" "tese" "geom" "frag" "comp" ] "glsl";
      };

    plugins = {
      treesitter = {
        enable = true;
        grammarPackages = with pkgs.olistrik; allGrammars ++ [
          tree-sitter-go-template
        ];
        settings = {
          highlight.enable = true;
          incremental_selection.enable = true;
          indent.enable = true;
        };
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
  };
}
