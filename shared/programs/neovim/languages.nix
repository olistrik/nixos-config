{pkgs, lib, vimPlugins ? pkgs.vimPlugins, grammars ? pkgs.tree-sitter.builtGrammars}:
let
  # this is annoying to type.
  tsRuntime = pkg: {
    "parser/${builtins.elemAt (lib.splitString "-" pkg.name) 2}.so".source = "${pkg}/parser";
  };

  # creates a lot of duplicate code, but it works.
  lspConfig = name: ''
    lua << EOF
    local nvim_lsp = require'lspconfig'

    local on_attach = function(client)
      require'completion'.on_attach(client)
    end

    nvim_lsp.${name}.setup { on_attach = on_attach }
    EOF
  '';
in {
    golang = rec {
      requires = with pkgs; [ gopls ];
      runtime = tsRuntime grammars.tree-sitter-go;
      config = lspConfig "gopls";
    };

    nix = rec {
      requires = with pkgs; [ rnix-lsp ];
      extras = with vimPlugins; [ vim-nix ];
      # runtime = tsRuntime suffix tree-sitter-nix;
      config = lspConfig "rnix";
    };

    c = rec {
      runtime = tsRuntime grammars.tree-sitter-c;
    };

    cpp = {
      config = ''
        "" Set tab width for C++
        autocmd FileType cpp setlocal textwidth=78 tabstop=4 shiftwidth=4 softtabstop=4 expandtab
      '';
    };

    tsx = rec {
      requires = with pkgs; [ nodePackages.typescript-language-server ];
      # extras = [ typescript-vim vim-jsx-typescript ];
      runtime = tsRuntime grammars.tree-sitter-tsx;
      config = lspConfig "tsserver" + ''
        " set .tsx and .jsx as typescriptreact ( this might not be needed anymore )
        autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact
      '';
    };

    ruby = rec {
      requires = with pkgs; [ kranex.rubocop-sdv solargraph ];
      extras = with vimPlugins; [ vim-rails ]; # Not sure if i need this?
      runtime = tsRuntime grammars.tree-sitter-ruby;
      config = (lspConfig "solargraph") + ''
        " Auto lint and fix ruby on save
        autocmd BufWritePost *.rb silent! !${pkgs.kranex.rubocop-sdv}/bin/rubocop -A <afile>
        autocmd BufWritePost *.rb edit
        autocmd BufWritePost *.rb redraw!
      '';
    };

    yaml = rec {
      runtime = tsRuntime grammars.tree-sitter-yaml;
    };
}
