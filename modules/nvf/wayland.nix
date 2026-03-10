{
  nvf.config.wayland =
    { pkgs, ... }:
    {
      vim = {
        clipboard.providers = {
          wl-copy.enable = true;
        };
      };
    };
}
