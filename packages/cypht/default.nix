{
  php,
  fetchFromGitHub,
  fetchurl,
  jq,
  lib,
}:
let
  # composer.lock pins henrique-borba/php-sieve-manager to a dist zip on
  # composer.tiki.org. That repo (and its cypht-org fork) have since been
  # disabled on GitHub, and the zip's own composer.json now identifies as
  # "cypht-org/php-sieve-manager" instead, which trips composer's package
  # identity check on install. Fetching the zip directly works fine outside
  # Nix's build sandbox, but reliably fails inside it ("Could not
  # authenticate against github.com"), so it's vendored here via a plain
  # Nix fetch and substituted in as a local `file://` dist below.
  sieveManagerDist = fetchurl {
    url = "https://composer.tiki.org/dist/henrique-borba/php-sieve-manager/henrique-borba-php-sieve-manager-845e59954c5418db50f3c6a134eb587660331f6e-zip-f98a2d.zip";
    sha256 = "15jmfr96zc0bwa3qqcrddnmmwlv2pns9plh24af1aghghivnv3g3";
  };
in
php.buildComposerProject2 (finalAttrs: {
  pname = "cypht";
  version = "2.12.2";

  src = fetchFromGitHub {
    owner = "cypht-org";
    repo = "cypht";
    tag = "v${finalAttrs.version}";
    hash = "sha256-56OlaFc9zWUhNBK/XtiPeIfPC1hdugF6kYlJj5+2Qgk=";
  };

  vendorHash = "sha256-g71bn7JyF8uP98LmJzX5xkT1/JgWcDX+QdUd2VeBmB0=";

  composerVendor = php.mkComposerVendor {
    inherit (finalAttrs) pname src version vendorHash;
    nativeBuildInputs = [ jq ];
    postPatch = ''
      # Copy out of the store first: a fixed-output derivation's output may not
      # reference /nix/store paths, and this file:// dist URL ends up baked
      # verbatim into vendor/composer/installed.json.
      cp ${sieveManagerDist} ./sieve-manager-dist.zip

      jq --arg dist "file://$(pwd)/sieve-manager-dist.zip" \
        '(.packages[] | select(.name == "henrique-borba/php-sieve-manager") | .name) = "cypht-org/php-sieve-manager"
          | (.packages[] | select(.name == "cypht-org/php-sieve-manager") | .dist.url) = $dist' \
        composer.lock > composer.lock.tmp
      mv composer.lock.tmp composer.lock

      jq '.require["cypht-org/php-sieve-manager"] = .require["henrique-borba/php-sieve-manager"] | del(.require["henrique-borba/php-sieve-manager"])' composer.json > composer.json.tmp
      mv composer.json.tmp composer.json
    '';
  };

  meta = {
    description = "Lightweight open source webmail aggregator, supporting IMAP/SMTP, JMAP and EWS";
    homepage = "https://cypht.org";
    license = lib.licenses.lgpl21Only;
    platforms = lib.platforms.linux;
  };
})
