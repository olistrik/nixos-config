{
  nvf.config.lsp =
    { my, lib, ... }:
    let
      inherit (lib.nvim.dag) entryAnywhere;
    in
    {
      # TODO: Why?
      imports = with my.modules.nvf; [ config.completion ];

      config.vim = {
        lsp = {
          enable = true;
          lspconfig.enable = true;
          # servers.ty.cmd = lib.mkForce ["ty" "server"];
        };

        languages = {
          enableFormat = true;
          enableTreesitter = true;
          nix = {
            enable = true;
            format.type = [ "nixfmt" ];
          };
          lua = {
            enable = true;
          };
          rust = {
            enable = true;
          };
          python = {
            enable = true;
            lsp.servers = [ "ty" ];
          };
        };

        luaConfigRC = {
          lsp-hover-highlight = entryAnywhere /* lua */ ''
            vim.api.nvim_create_autocmd("LspAttach", {
            	callback = function(args)
            		local client = vim.lsp.get_client_by_id(args.data.client_id)
            		if client:supports_method("textDocument/documentHighlight") then
            			vim.cmd([[
                    augroup lsp_document_highlight
                      autocmd! * <buffer>
                      autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                      autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
                    augroup END
                  ]])
            		end
            	end,
            })
          '';
        };
      };
    };

  nvf.config.keymaps = {
    config.vim.lsp.mappings = {
      goToDefinition = "gd";
      goToDeclaration = "gD";
      goToType = "gt";

      listReferences = "gr";
      listImplementations = "gi";
      listDocumentSymbols = "gs";

      hover = "K";
      signatureHelp = "gk";
      codeAction = "ga";

      format = "<leader>fm";
      renameSymbol = "<leader>rn";

      previousDiagnostic = "g[";
      nextDiagnostic = "g]";
    };
  };
}
