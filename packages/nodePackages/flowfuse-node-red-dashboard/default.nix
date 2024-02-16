{ buildNpmPackage, fetchFromGitHub }: buildNpmPackage rec {
  pname = "node-red-dashboard";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "FlowFuse";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-/EU0aza8zcjUp+t8mO54iGWU6BwAPJb1urj9EHAjkws=";
  };

  postPatch = ''
    sed -i '/"cypress"/d' package.json
  '';

  npmDepsHash = "sha256-BeUM9NK9AAgF2ln2gFrigr8xzOdN7qFU6dIRVY7vlwo=";
  npmPackFlags = [ "--ignore-scripts" ];
}
