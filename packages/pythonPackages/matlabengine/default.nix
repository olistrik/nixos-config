{ fetchFromGitHub, python3Packages }:
python3Packages.buildPythonPackage rec {
  pname = "matlabengine";
  version = "24.2.1";

  src = fetchFromGitHub {
    owner = "mathworks";
    repo = "matlab-engine-for-python";
    rev = version;
    sha256 = "sha256-idRPp0XzutsF/rPmpnbCbyVwqL6Mwmc6hRq6anPwA2k=";
  };
}
