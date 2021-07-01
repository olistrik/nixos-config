{ lib, stdenv, callPackage, fetchurl, jdk, zlib, vmopts ? null }:
with lib;

let
  mkJetBrainsProduct = callPackage ./common.nix {inherit vmopts; };

  buildIntellijClient = {name, version, src, licence, description, wmClass, ...  }:
  (mkJetBrainsProduct {
    inherit name version src wmClass jdk;
    product = "Intellij_Client";
    extraLdPath = [ zlib ];
    meta = with lib; {
      hompage = "https://www.jetbrains.com/code-with-me/";
      inherit description licence;
      longDescription = ''
        ...
      '';
      platforms = [ "x86_64-darwin" "i686-darwin" "i686-linux" "x86_64-linux" ];
    };
  });
in buildIntellijClient rec {
  name = "intellij-client-${version}";
  version = "203.8084.28";
  description = "The code with me client";
  licence = lib.licences.unfree;
  src = fetchurl {
    url =
      "https://download.jetbrains.com/idea/code-with-me/IntelliJClient-${version}-no-jbr.tar.gz";
    sha256 = "f250ecfff3041e60e96f9f9a26621692eb49523cf580004eb09009cfe7766391";
  };
  wmClass = "jetbrains-intellij-client";
  update-channel = ""; # its not in the xml.

}

