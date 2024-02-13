{ stdenv, fetchSteam, autoPatchelfHook }: stdenv.mkDerivation rec {
  name = "palworld";
  version = "6370735655629434989";

  src = fetchSteam
    {
      inherit name;
      appId = "2394010";
      depotId = "2394012";
      manifestId = version;
      hash = "sha256-CQprrt8KO40QabW0F3V6UsFDf32CA+U9C5HkLQenlQQ=";
    };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -a $src/. $out 

    # You may need to fix permissions on the main executable.
    chmod +x $out/some_server_executable

    runHook postInstall
  '';
}
