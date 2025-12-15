# Temporary overlay for unstable packages.
{ channels, ... }: final: prev: {
  inherit (channels.unstable) caddy;

  # WARN: REMOVE IN 25.11
  inherit (channels.unstable) nextcloud32;
}
