{ lib, pkgs, config, ... }:
with lib;
with lib.olistrik;
with lib.olistrik.nixvim;
mkPlugin "lsp" {
  inherit config;
  plugins = {
    lsp = {
      servers = {
        nil_ls = {
          extraOptions.settings.nil = {
            formatting.command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
          };
        };
        # gopls = enabled;
        # eslint = enabled;
        # tsserver = enabled;
        # rust-analyzer = enabled;
      };

      keymaps = {
        silent = true;
        lspBuf = {
          "gd" = "definition";
          "gD" = "implementation";
          "gk" = "signature_help";
          "0gD" = "type_definition";
          "gr" = "references";
          "g-1" = "document_symbol";
          "ga" = "code_action";
          "K" = "hover";
          "<C-]>" = "declaration";
          "<leader>fm" = "format";
          "<leader>rn" = "rename";
        };
        diagnostic = {
          "g[" = "goto_prev";
          "g]" = "goto_next";
        };
      };
    };

    nvim-cmp = {
      enable = true;

      snippet.expand = "luasnip";

      mapping = {
        "<C-d>" = "cmp.mapping.scroll_docs(-4)";
        "<C-f>" = "cmp.mapping.scroll_docs(4)";
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-e>" = "cmp.mapping.close()";
        "<CR>" = "cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert })";
        "<Tab>" = "cmp.mapping.select_next_item()";
        "<S-Tab>" = "cmp.mapping.select_prev_item()";
      };

      sources = [
        { name = "nvim_lsp"; }
        { name = "buffer"; }
        { name = "path"; }
      ];
    };

    lsp-format.enable = true;
    luasnip.enable = true;
  };
}
