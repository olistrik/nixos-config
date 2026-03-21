{ buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "node-red-contrib-esphome";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "twocolors";
    repo = pname;
    rev = "0.3.3";
    hash = "sha256-3FcybyptRGozzM7rsENMGT+SUe1ecv/eHfvIzKSRWbU=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-/kcr6byiU17cIM+fqjKFY6Tk1xuA8CUJqFsbIvxLTkA=";
  npmPackFlags = [ "--ignore-scripts" ];
}
