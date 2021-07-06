{ stdenv, fetchurl, autoPatchelfHook, unzip, jdk8 }:
let

  VERSION = "4.1.1";
  TIZEN_URL = "http://download.tizen.org/sdk/Installer/tizen-studio_${VERSION}/web-ide_Tizen_Studio_${VERSION}_ubuntu-64.bin";
  TIZEN_SHA256 = "7S+OCBD+iebt+R5RUH7wzAgN2rtiI4mWOgn1MTtXJ3U=";


in stdenv.mkDerivation {
  name = "tizen-studio";

  buildInputs = [ jdk8 unzip ];

  src = fetchurl {
    url = TIZEN_URL;
    sha256 = TIZEN_SHA256;
  };

  unpackPhase = ''
  FILE_OFFSET=$(head $src | grep ORI_FILE_LEN | cut -d\" -f2)
  tail -n +''$FILE_OFFSET $src | tar xmz
  '';

  installPhase = ''
  mkdir -p $out/{bin,tizen-studio}

  ${unzip}/bin/unzip tizen-sdk.zip -d $out/tizen-studio

  rm -rf $out/tizen-studio/jdk

  echo TIZEN_SDK_INSTALLED_PATH=$out/tizen-studio > $out/tizen-studio/sdk.info
  echo TIZEN_SDK_DATA_PATH=\$HOME/tizen-studio-data >> $out/tizen-studio/sdk.info
  '';

}

