{
  nvf.config.wayland =
    { lib, ... }:
    {
      vim = {
        clipboard.providers.wl-copy.enable = true;

        luaConfigRC.osc52-clipboard-fallback = lib.nvim.dag.entryAfter [ "basic" ] /* lua */ ''
          if vim.env.WAYLAND_DISPLAY == nil then
            vim.g.clipboard = "osc52"
          end
        '';
      };
    };
}
