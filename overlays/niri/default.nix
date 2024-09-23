{ channels, ... }: final: prev: {
  inherit (channels.unstable) niri;
  # Niri requires same packageset mesa. This also causes issues when building QT programs.
  # TODO: Might be better to just replace mesa?
  unstable-mesa = channels.unstable.mesa;
}
