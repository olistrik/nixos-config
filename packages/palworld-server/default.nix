{ lib
, stdenv
, fetchSteam
, autoPatchelfHook
, steamworks-sdk-redist
, xdg-user-dirs
, saveDirectory ? null

}:
let
  steamworks-sdk = steamworks-sdk-redist.overrideAttrs (prev: {
    src = fetchSteam {
      inherit (prev) name;
      appId = "1007";
      depotId = "1006";
      manifestId = "4884950798805348056";
      hash = "sha256-hPa4ACMqM+QVkP2M2/zQ3+oUTu8QU0eLHjlD09Ge2yA=";
    };
  });
in
stdenv.mkDerivation rec {
  name = "palworld-server";
  version = "3750364703337203431";

  src = fetchSteam
    {
      inherit name;
      appId = "2394010";
      depotId = "2394012";
      manifestId = version;
      hash = "sha256-xywzbb5AqZPjGmLv+16I0Yi21pMfphvVPycDPsuv0mo=";
    };
  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ stdenv.cc.cc.libgcc ];

  propagatedBuildInputs = [ steamworks-sdk xdg-user-dirs ];

  installPhase =
    assert lib.asserts.assertMsg (saveDirectory != null) "palworld saveDirectory must be explicitly provided";
    ''
      runHook preInstall

      mkdir -p $out/bin
      mkdir -p $out/dist
      cp -a $src/. $out/dist

      server=$out/dist/Pal/Binaries/Linux/PalServer-Linux-Test
      chmod +x $server
      chmod +x $out/dist/PalServer.sh
      chmod -R +w $out/dist

      ln -s $out/dist/PalServer.sh $out/bin/palworld-server 
      ls -l $out/bin
      ls -l $out/dist
      ln -s ${saveDirectory} $out/dist/Pal/Saved
      runHook postInstall
    '';
}
