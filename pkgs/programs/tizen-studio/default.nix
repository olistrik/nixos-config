{ stdenv, fetchurl, autoPatchelfHook, unzip, jdk8,
  fontconfig, freetype, glib, gsettings-desktop-schemas, gtk2, libX11,
  libXrender, libXtst, zlib,
  tizen-data ? "/home/kranex/.tizen-studio-data"
}:
let

  VERSION = "4.1.1";
  TIZEN_URL = "http://download.tizen.org/sdk/Installer/tizen-studio_${VERSION}/web-ide_Tizen_Studio_${VERSION}_ubuntu-64.bin";
  TIZEN_SHA256 = "7S+OCBD+iebt+R5RUH7wzAgN2rtiI4mWOgn1MTtXJ3U=";


in stdenv.mkDerivation {
  name = "tizen-studio";

  buildInputs = [
    jdk8 unzip
    fontconfig freetype glib gsettings-desktop-schemas gtk2 libX11
    libXrender libXtst zlib
  ];

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

  # unpack tizen studio
  ${unzip}/bin/unzip tizen-sdk.zip -d $out/tizen-studio

  # we're going to use our own so get rid of this junk.
  rm -rf $out/tizen-studio/jdk

  # Create the stupid sdk.info
  echo TIZEN_SDK_INSTALLED_PATH=$out/tizen-studio > $out/tizen-studio/sdk.info
  echo TIZEN_SDK_DATA_PATH=${tizen-data} >> $out/tizen-studio/sdk.info
  echo JDK_PATH=${jdk8} >> $out/tizen-studio/sdk.info

  # replace the stupid sdk.info sdkDataPath with one in the current users home
  # dir. This is absolutely rediculous btw.
  # grep -rl 'sdkDataPath=' $out/tizen-studio | \
  # xargs sed -i '2isdkDataPath=\"\$HOME/tizen-sdk-data\"'

  # update eclipse ini path
  sed -i "/-vm$/{N;P;s|.*\n||;s|.*|${jdk8}/bin/java|;}" \
  $out/tizen-studio/ide/eclipse.ini
  sed -i "s|updateIniFile \".*\"|echo ini already updated by nixos|g" $out/tizen-studio/ide/TizenStudio.sh
  '';

}

