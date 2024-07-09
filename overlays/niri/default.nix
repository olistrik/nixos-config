{ channels, ... }: final: prev: {
  inherit (channels.unstable) niri;
  unstable-mesa = channels.unstable.mesa;
}
