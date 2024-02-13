{ callPackage, ... }:
builtins.mapAttrs (name: deriv: callPackage deriv { })
  {
    screencapture-scripts = ./scripts/screencapture;
    code-with-me = ./programs/code-with-me;
    git-graph = ./programs/git-graph;
    git-igitt = ./programs/git-igitt;
    atlas = ./programs/atlas;
    nvim = ./configured/neovim;
    palworld-server = ./programs/palworld-server;

    vimPlugins = ./vimPlugins;
    nodePackages = ./nodePackages;
    rubyPackages = ./rubyPackages;
    tree-sitter-grammars = ./tree-sitter-grammars;
  } // { }
