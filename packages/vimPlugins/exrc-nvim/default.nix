{ vimUtils, fetchFromGitHub }:
vimUtils.buildVimPlugin rec {
  name = "exrc.nvim";
  version = "e00b5778dd42daf3a68f2200437dff5e2208083d";

  src = fetchFromGitHub {
    owner = "jedrzejboczar";
    repo = name;
    rev = version;
    sha256 = "5ZsR1VM7AqzeOSqRqh4o0AKy2be/7yeQsv5xGrKO4bI=";
  };
}
