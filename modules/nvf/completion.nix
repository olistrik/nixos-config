{
  nvf.config.completion = {
    config.vim = {
      autocomplete.blink-cmp = {
        enable = true;
        setupOpts = {
          completion = {
            ghost_text.enabled = true;
            list.selection = {
              preselect = false;
            };
          };
          sources.default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];
        };
      };
    };
  };

  nvf.config.keymaps = {
    config.vim.autocomplete.blink-cmp.mappings = {
      complete = "<C-Space>";
      confirm = "<CR>";
      next = "<Tab>";
      previous = "<S-Tab>";
      close = "<C-e>";
      scrollDocsUp = "<C-d>";
      scrollDocsDown = "<C-f>";
    };
  };
}
