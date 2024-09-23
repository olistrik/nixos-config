# Temporary overlay for unstable packages.
{ channels, ... }: final: prev: {
  inherit (channels.unstable)
    # Not yet in 24.05.
    git-igitt
    xwayland-satellite
    ;
}
