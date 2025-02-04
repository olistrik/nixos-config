# Temporary overlay for unstable packages.
{ channels, ... }: final: prev: {
  # inherit (channels.unstable) ...;

  vimPlugins = prev.vimPlugins // {
    inherit (channels.unstable.vimPlugins)
      codecompanion-nvim;
  };
}
