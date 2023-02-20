{ stdenv, bundlerEnv, ruby, bundix, fetchFromGitHub }:
let
  name = "git-chain";
  version = "e1c0ef1";

  src = fetchFromGitHub {
    owner = "Shopify";
    repo = name;
    rev = "${version}";
    sha256 = "sha256-5OUUf5nC++IHZ9TwXhdkLC1IkfhWmwoqCK8kRKYjlNc=";
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
