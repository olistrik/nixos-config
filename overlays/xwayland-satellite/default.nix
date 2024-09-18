{ channels, ... }: final: prev: {
  inherit (channels.unstable) xwayland-satellite;
}
