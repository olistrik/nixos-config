{ vimUtils, fetchFromGitHub }:
vimUtils.buildVimPlugin rec {
  name = "go.nvim";
  version = "v0.2.2-281b51a";

  src = fetchFromGitHub {
    owner = "ray-x";
    repo = name;
    rev = "281b51a";
    sha256 = "sha256-euIkt78R27CDmlCqMUIROhw5cgFbwPw5LZy3ak1kq7w=";
  };
}
