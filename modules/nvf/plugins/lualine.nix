{
  nvf.config.lualine =
    { config, ... }:
    {
      config.vim = {
        statusline.lualine = {
          enable = true;
        };
      };
    };
}
