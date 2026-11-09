{ pkgs, ... }:

let
  base = pkgs.caddy.withPlugins {
    plugins = [
      "github.com/tailscale/caddy-tailscale@v0.0.0=github.com/olistrik/caddy-tailscale@v0.0.0-20261109143848-accb17d43fad"
    ];
    hash = "sha256-+zeq0WyQ2ar81RwcdpHj0XziYRK6uT1/iFoq0w6grJU=";

    doInstallCheck = false;
  };
in

# The src derivation (xcaddy build environment) is a fixed-output stdenv.mkDerivation
# inside caddy.overrideAttrs. We need GOPRIVATE scoped to just the fork so Go fetches
# it directly and skips sum.golang.org (which 404s on it) without forcing every other
# module (e.g. cel-go) through direct git fetches, which fail with no credential
# helper in the sandbox.
base.overrideAttrs (prev: {
  src = prev.src.overrideAttrs (srcPrev: {
    GOPRIVATE = "github.com/olistrik/caddy-tailscale";
  });
})
