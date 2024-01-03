{ vimUtils, fetchFromGitHub }:
vimUtils.buildVimPlugin rec {
  name = "scss-syntax.vim";
  version = "bda22a93d1dcfcb8ee13be1988560d9bb5bd0fef";

  src = fetchFromGitHub {
    owner = "cakebacker";
    repo = name;
    rev = version;
    sha256 = "azO+Eay3V9aLyJyP1hmKiEAtr6Z3OqlWVu4v2GEoUdo=";
  };
}
