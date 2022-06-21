{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "git-igitt";
  version = "0.1.15";

  src = fetchFromGitHub {
    owner = "mlange-42";
    repo = pname;
    rev = version;
    sha256 = "v9kgGL8T73yhoGOmn5G+vvKu6712OOFrdnj/Ky6dAhA=";
  };

  cargoSha256 = "GKwUmU/Tl0Ig0CrBRqnXTCE7eeDEyCHmOvjX8Boccm0=";

  meta = with lib; {
    description =
      "Interactive, cross-platform Git terminal application with clear git graphs arranged for your branching model";
    homepage = "https://github.com/mlange-42/git-igitt";
    licence = licences.mit;
    maintainers = [ ];
  };
}
