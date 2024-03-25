{ channels, ...}: final: prev: {
  inherit (channels.unstable) sigrok-cli;
}
