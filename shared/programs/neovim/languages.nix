{pkgs, lib, vimPlugins ? pkgs.vimPlugins, grammars ? pkgs.tree-sitter.builtGrammars}:
let
  # creates a lot of duplicate code, but it works.
  lspConfig = name: setup: ''
    lua <<EOF
    require'lspconfig'.${name}.setup {${setup}}
    EOF
  '';

  tsserver = pkgs.nodePackages.typescript-language-server.overrideAttrs ( oldAttrs: rec {
    src = pkgs.fetchFromGitHub {
      owner = "theia-ide";
      repo = "typescript-language-server";
      rev = "9ce7aa4ae399a5b66ea0bc027447a14aed273e3a";
      sha256 = "rknONZq+EG1aFZPdgSwcGihC99+1jy34xpPid49jE6M=";
    };
  });
in {
    golang = rec {
      requires = with pkgs; [ gopls go ];
      config = lspConfig "gopls" "" + ''
        " Auto format go on save
        autocmd Filetype go setlocal noexpandtab
        autocmd BufWritePost *.go silent! !${pkgs.go}/bin/go fmt <afile>
        autocmd BufWritePost *.go edit
        autocmd BufWritePost *.go redraw!
      '';
    };

    nix = rec {
      requires = with pkgs; [ rnix-lsp ];
      extras = with vimPlugins; [ vim-nix ];
      config = lspConfig "rnix" "";
    };

    c = rec {
    };

    cpp = {
      config = ''
        "" Set tab width for C++
        autocmd FileType cpp setlocal textwidth=78 tabstop=4 shiftwidth=4 softtabstop=4 expandtab
      '';
    };

    js = rec {
    };

    tsx = rec {
    };

    ts = rec {
      requires = with pkgs; [ nodePackages.typescript-language-server nodePackages.typescript];
      config = lspConfig "tsserver" ''
        cmd = { 'typescript-language-server', '--stdio', '--tsserver-path',
        '${pkgs.nodePackages.typescript}/bin/tsserver' }
      '';
    };

    ruby = rec {
      requires = with pkgs; [ kranex.rubocop-sdv solargraph ];
      extras = with vimPlugins; [ vim-rails ]; # Not sure if i need this?
      config = (lspConfig "solargraph" "") + ''
        " Auto lint and fix ruby on save
        autocmd BufWritePost *.rb silent! !${pkgs.kranex.rubocop-sdv}/bin/rubocop -A <afile>
        autocmd BufWritePost *.rb edit
        autocmd BufWritePost *.rb redraw!
      '';
    };

    yaml = rec {
    };

    python = rec {
      requires = with pkgs; [ pyright ];
      config = lspConfig "pyright" "";
    };
}
