{ buildNpmPackage, fetchFromGitHub }: buildNpmPackage rec {
  pname = "node-red-contrib-toggle";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "eschava";
    repo = pname;
    rev = "3d8bd7d";
    hash = "sha256-lm1Lunko04r1q8ef5XAtM5+BlBhOxw9yomjtwmU7pnc=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    mkdir -p node_modules
  '';

  npmDepsHash = "sha256-Ldxwi8OYqvT/rzmuiGZlRt6FkYbhdv4gUJZZ0Us4bd0=";
  npmPackFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;
  forceEmptyCache = true;
}
