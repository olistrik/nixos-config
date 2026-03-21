{ buildNpmPackage, fetchFromGitHub }: buildNpmPackage rec {
  pname = "node-red-contrib-esphome";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "twocolors";
    repo = pname;
    rev = "488a62a";
    hash = "sha256-nkbaluTFDQ1csC/XjhVTevJzi05RXTGV4/9+0cvtouM=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-2adeWfiZnWH64AKmSCVshlogugc0dWoQpTK51CZ0NMs=";
  npmPackFlags = [ "--ignore-scripts" ];
}
