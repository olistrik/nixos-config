{ buildNpmPackage, fetchFromGitHub }: buildNpmPackage rec {
  pname = "node-red-contrib-wiz-local-control";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "heleon19";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Ch49p/xBCnRroHdM9Yuk8pgvmL5yDNDpckq0XFgIu34=";
  };


  npmDepsHash = "sha256-7djLkSSG3LW9EddNIX2wZjTmYnu6muz3EP5ieIA0qAM=";
  npmPackFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;
}
