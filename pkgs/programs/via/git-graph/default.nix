{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "git-graph";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "mlange-42";
    repo = pname;
    rev = version;
    sha256 = "a28X+EJsZ03TPvFDlxybuf1CVzgXgiFCO7t1jBBBdfY=";
  };

  cargoSha256 = "QrPn7aqBo9WBn826QE2PSKvY6Nr2sWZ0juSFSTVo7GM=";

  meta = with lib; {
    description = "Command line tool to show clear git graphs arranged for your branching model.";
    homepage = "https://github.com/mlange-42/git-graph";
    licence = licences.mit;
    maintainers = [];
  };
}
