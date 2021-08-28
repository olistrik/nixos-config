{ pkgs }:

pkgs.vimUtils.buildVimPlugin {
  patches = [ ./no_tests.patch ];
  name = "nvim-ts-autotag";
  src = pkgs.fetchFromGitHub {
    owner = "windwp";
    repo = "nvim-ts-autotag";
    rev = "99ba1f6d80842a4d82ff49fc0aa094fb9d199219";
    sha256 = "NJHxsL7oF7ZRKOlFMpEdcWoBH+/21Pk0uy5ljmlHe4c=";
  };
}
