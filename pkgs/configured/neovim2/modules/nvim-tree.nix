{ pkgs, dsl, ... }:
with dsl; {
  plugins = with pkgs.unstable.vimPlugins; [ nvim-tree-lua ];

  setup.nvim-tree = {
    disable_netrw = false;
    hijack_netrw = false;
    open_on_setup = false;
    ignore_ft_on_setup = { };
    open_on_tab = false;
    hijack_cursor = true;
    update_cwd = false;
    hijack_directories = {
      enable = true;
      auto_open = true;
    };
    renderer = {
      special_files = [ "README.md" "Makefile" "MAKEFILE" ];
      group_empty = true;
      icons = {
        show = {
          git = true;
          folder = true;
          file = true;
          folder_arrow = true;
        };

        glyphs = {
          default = "";
          symlink = "";
          git = {
            unstaged = "✗";
            staged = "✓";
            unmerged = "";
            renamed = "➜";
            untracked = "★";
            deleted = "";
            ignored = "◌";
          };
          folder = {
            arrow_open = "";
            arrow_closed = "";
            default = "";
            open = "";
            empty = "";
            empty_open = "";
            symlink = "";
            symlink_open = "";
          };
        };
      };
    };
    actions = {
      open_file = {
        resize_window = true;
        window_picker = {
          exclude = {
            filetype = [ "packer" "qf" ];
            buftype = [ "terminal" ];
          };
        };
      };
    };
    diagnostics = {
      enable = true;
      icons = {
        hint = "";
        info = "";
        warning = "";
        error = "";
      };
    };
    update_focused_file = {
      enable = true;
      update_cwd = false;
      ignore_list = { };
    };
    system_open = {
      cmd = null;
      args = { };
    };
    filters = {
      dotfiles = false;
      custom = [ ".git" "node_modules" ".cache" "vendor" ];
    };
    git = {
      enable = true;
      ignore = true;
      timeout = 500;
    };
    view = {
      width = 40;
      height = 30;
      hide_root_folder = false;
      side = "left";
      mappings = {
        custom_only = false;
        list = { };
      };
      number = false;
      relativenumber = false;
    };
    trash = {
      cmd = "trash";
      require_confirm = true;
    };

  };

  nnoremap."<C-n" = ":NvimTreeFindFileToggle<CR>";
  nnoremap."<leader>-r>" = ":NvimTreeRefresh<CR>";
  nnoremap."<leader>-n>" = ":NvimTreeFindFile<CR>";
}
