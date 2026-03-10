{
  nvf.config.telescope =
    {
      _,
      pkgs,
      config,
      lib,
      options,
      ...
    }:
    {
      imports = with _.modules.nvf.plugins; [
        telescope-file-browser
        telescope-fzf-native
      ];

      vim.telescope.enable = true;
    };

  nvf.config.keymaps = {
    config.vim.telescope.mappings = {
      findFiles = "<C-p>";
      liveGrep = "<C-f>";

      # telescope-file-browser.nvim
      browseRelative = "<leader><tab>";
    };
  };
}
