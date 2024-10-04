{ inputs, ... }: final: prev: {
  # nixpkgs is behind, unstable breaks mesa, niri-flake.nixosModules does a little too much.
  niri = prev.niri-stable;
  xwayland-satellite = prev.xwayland-satellite-unstable.overrideAttrs (finalAttrs: prevAttrs: {
    cargoBuildFlags = [ "--features=systemd" ];
  });
}
