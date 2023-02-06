{ pkgs, fetchFromGitHub }:
let angularls = fetchFromGitHub { };
in with pkgs; {
  screencapture-scripts = callPackage ./scripts/screencapture { };
  code-with-me = callPackage ./programs/code-with-me { };
  git-graph = callPackage ./programs/git-graph { };
  git-igitt = callPackage ./programs/git-igitt { };
  atlas = callPackage ./programs/atlas { };
  nvim = callPackage ./configured/neovim { };
  # nvim2 = callPackage ./configured/neovim2 { };

  vimPlugins = callPackage ./vimPlugins { };
  nodePackages = callPackage ./nodePackages { };
  rubyPackages = callPackage ./rubyPackages { };
}
