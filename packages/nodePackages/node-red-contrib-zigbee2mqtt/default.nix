{ buildNpmPackage, fetchFromGitHub }: buildNpmPackage rec {
  pname = "node-red-contrib-zigbee2mqtt";
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "andreypopov";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-WiMn7s6ER/lAG2EZmFavMW+mkY1ISkATIuQcuxFu4GI=";
  };

  npmDepsHash = "sha256-k4GNF/VEexAndvJM31oDXvKPB+tHfgRBNB0DSvU32l4=";
  npmPackFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;
}
