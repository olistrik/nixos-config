{pkgs, lib, vimPlugins ? pkgs.vimPlugins, grammars ? pkgs.tree-sitter.builtGrammars}:
let
  # this is annoying to type.
  tsRuntime = pkg: {
    "parser/${builtins.elemAt (lib.splitString "-" pkg.name) 2}.so".source = "${pkg}/parser";
  };

  # creates a lot of duplicate code, but it works.
  lspConfig = name: setup: ''
    lua << EOF
    require'lspconfig'.${name}.setup {${setup}}
    EOF
  '';
in {
    golang = rec {
      requires = with pkgs; [ gopls ];
      runtime = tsRuntime grammars.tree-sitter-go;
      config = lspConfig "gopls" "";
    };

    nix = rec {
      requires = with pkgs; [ rnix-lsp ];
      extras = with vimPlugins; [ vim-nix ];
      # runtime = tsRuntime suffix tree-sitter-nix;
      config = lspConfig "rnix" "";
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
      runtime = tsRuntime grammars.tree-sitter-tsx;
    };

    ts = rec {
      requires = with pkgs; [ nodePackages.typescript nodePackages.typescript-language-server ];
      runtime = tsRuntime grammars.tree-sitter-typescript;
      config = lspConfig "tsserver" "";
    };

    ruby = rec {
      requires = with pkgs; [ kranex.rubocop-sdv solargraph ];
      extras = with vimPlugins; [ vim-rails ]; # Not sure if i need this?
      runtime = tsRuntime grammars.tree-sitter-ruby;
      config = (lspConfig "solargraph" "") + ''
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
