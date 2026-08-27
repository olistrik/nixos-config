{ lib, fetchurl, stdenv, ... }:

let
  version = "15.5.8";
in
stdenv.mkDerivation {
  pname = "omp";
  inherit version;

  src = fetchurl {
    url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
    hash = "sha256-G3cVnc1y4O6y3RQtpcJdumCmt1VbuebV4Iou6Hv8Rbk=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/omp
    chmod +x $out/bin/omp
  '';

  meta = {
    description = "Oh My Pi - coding agent";
    homepage = "https://github.com/can1357/oh-my-pi";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = [ "x86_64-linux" ];
  };
}
