{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  makeWrapper,
}:

let
  version = "3.9.0";

  src = fetchFromGitHub {
    owner = "maathimself";
    repo = "mailflow";
    rev = "b5334759ed8ef7f667e531660905ece177487bb5";
    hash = "sha256-06unvD88fC7sh4Ycf1u5vg/NJ4bQDEzN15UlWB/+woI=";
  };

  frontend = buildNpmPackage {
    pname = "mailflow-frontend";
    inherit version src;
    sourceRoot = "${src.name}/frontend";
    nodejs = nodejs_22;
    npmDepsHash = "sha256-3lkR05hHAR+beva6eH5GdlLTKuK8SVLDj2e5lxmvtUk=";

    # electron is only used for desktop packaging, never by the vite build.
    env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  };

  backend = buildNpmPackage {
    pname = "mailflow-backend";
    inherit version src;
    sourceRoot = "${src.name}/backend";
    nodejs = nodejs_22;
    npmDepsHash = "sha256-PRtKu7cXshzoozf6ExhnkjZu+IjtUMRBOJSXL9ov9NU=";

    dontNpmBuild = true;
    npmFlags = [ "--omit=dev" ];

    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/mailflow $out/bin
      cp -r package.json node_modules src migrations $out/lib/mailflow/
      printf '{"version":"%s"}\n' "${version}" > $out/lib/mailflow/build-meta.json
      makeWrapper ${lib.getExe nodejs_22} $out/bin/mailflow-backend \
        --add-flags $out/lib/mailflow/src/index.js
      runHook postInstall
    '';

    meta.mainProgram = "mailflow-backend";
  };
in
{
  inherit frontend backend;
}
