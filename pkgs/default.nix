{ pkgs }:
with pkgs; {
  screencapture-scripts = callPackage ./scripts/screencapture { };
  code-with-me = callPackage ./programs/code-with-me { };
  git-graph = callPackage ./programs/git-graph { };
  git-igitt = callPackage ./programs/git-igitt { };
  nvim = callPackage ./configured/neovim { };
  nvim2 = callPackage ./configured/neovim2 { };

  nodePackages = callPackage ./node-packages { };
  vimPlugins = { };
}
