{ vimUtils, fetchFromGitHub }:
vimUtils.buildVimPluginFrom2Nix rec {
  name = "go.nvim";
  version = "v0.2.1";

  src = fetchFromGitHub {
    owner = "ray-x";
    repo = name;
    rev = version;
    sha256 = "azO+Eay3V9aLyJyP1hmKiEAtr6Z3OqlWVu4v2GEoUdo=";
  };
}
