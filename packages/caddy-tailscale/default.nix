{ pkgs, ... }:

let
  base = pkgs.caddy.withPlugins {
    plugins = [
      "github.com/tailscale/caddy-tailscale@v0.0.0=github.com/olistrik/caddy-tailscale@v0.0.0-20260709152620-9630b5196abf"
    ];
    hash = "sha256-dVt/b+kURSu60+f/5IghJN5v8UtiTp08JbFIadqG0LA=";

    doInstallCheck = false;
  };
in

# The src derivation (xcaddy build environment) is a fixed-output stdenv.mkDerivation
# inside caddy.overrideAttrs. We need GONOSUMCHECK/SUMDB/GOPROXY set there so Go
# doesn't try to verify the fork's checksum against sum.golang.org (which returns 404).
base.overrideAttrs (prev: {
  src = prev.src.overrideAttrs (srcPrev: {
    GONOSUMCHECK = "*";
    GONOSUMDB = "*";
    GOPROXY = "direct";
  });
})
