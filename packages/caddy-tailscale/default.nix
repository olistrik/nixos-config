{ pkgs, ... }:

let
  base = pkgs.caddy.withPlugins {
    plugins = [
      "github.com/tailscale/caddy-tailscale@v0.0.0=github.com/olistrik/caddy-tailscale@v0.0.0-20260709152620-9630b5196abf"
    ];
    hash = "sha256-z6wM9hIXzUD29DCOLVAppto6uonkerG+CEFa/8OP/H8=";

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
