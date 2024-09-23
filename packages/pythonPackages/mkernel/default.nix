{ inputs, lib, fetchFromGitHub, python3Packages, pkgs }:
python3Packages.buildPythonPackage rec {
  pname = "mkernel";
  version = "1.1.0";

  format = "pyproject";

  src = fetchFromGitHub {
    owner = "allefeld";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-xJeHp7m2Jyd8xx8kyK3k2RkCgCdRRaJ4hmejRY8zeuQ=";
  };

  propagatedBuildInputs = with python3Packages; [
    ipykernel
    wurlitzer
    inputs.nix-matlab.packages.${pkgs.system}.matlab-python-package
  ];

  buildInputs = with python3Packages; [
    hatchling
  ];
}
