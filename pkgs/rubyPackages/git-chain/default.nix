{ stdenv, bundlerEnv, ruby, bundix, fetchFromGitHub }:
let
  name = "git-chain";
  version = "9dea3fa";

  src = fetchFromGitHub {
    owner = "Shopify";
    repo = name;
    rev = "${version}";
    sha256 = "sha256-vLqvWlliTimBHuCwwzDOe4+1zli1lhd1LX4ReGQraIU=";
  };

  gems = bundlerEnv {
    inherit name ruby;
    gemdir = ./.;
  };
in stdenv.mkDerivation {
  inherit name version src;
  buildInputs = [ gems ruby ];
  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out
  '';
}
