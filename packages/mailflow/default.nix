{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  makeWrapper,
}:

let
  version = "4.3.0";

  src = fetchFromGitHub {
    owner = "maathimself";
    repo = "mailflow";
    rev = "1b5dbfdbc32f318ee90d6ec9ed3e0a7556487cbc";
    hash = "sha256-1PboNZkHn6SRuyYy0huGmtZ4Cf/MLbGDwCszb8t31Hw=";
  };

  frontend = buildNpmPackage {
    pname = "mailflow-frontend";
    inherit version src;
    sourceRoot = "${src.name}/frontend";
    nodejs = nodejs_22;
    npmDepsHash = "sha256-J1Dv+WjgDesJJ8z/957QoBTRUV5aKmf4M4LijfRpd4c=";

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
    npmDepsHash = "sha256-amd5hK5YKJvoApkwXS2P1Iknm4nBtuRsxlSQzev8VFg=";

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
