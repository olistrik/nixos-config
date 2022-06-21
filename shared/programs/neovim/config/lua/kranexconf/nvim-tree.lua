vim.cmd([[
" Dictionary of buffer option names mapped to a list of option values that
" indicates to the window picker that the buffer's window should not be
" selectable.
let g:nvim_tree_special_files = { 'README.md': 1, 'Makefile': 1, 'MAKEFILE': 1 } " List of filenames that gets highlighted with NvimTreeSpecialFile
let g:nvim_tree_show_icons = {
\ 'git': 1,
\ 'folders': 1,
\ 'files': 1,
\ 'folder_arrows': 1,
\ }
"If 0, do not show the icons for one of 'git' 'folder' and 'files'
"1 by default, notice that if 'files' is 1, it will only display
"if nvim-web-devicons is installed and on your runtimepath.
"if folder is 1, you can also tell folder_arrows 1 to show small arrows next to the folder icons.
"but this will not work when you set indent_markers (because of UI conflict)
" default will show icon by default if no icon is provided
" default shows no icon by default
let g:nvim_tree_icons = {
\ 'default': '',
\ 'symlink': '',
\ 'git': {
\   'unstaged': "✗",
\   'staged': "✓",
\   'unmerged': "",
\   'renamed': "➜",
\   'untracked': "★",
\   'deleted': "",
\   'ignored': "◌"
\   },
\ 'folder': {
\   'arrow_open': "",
\   'arrow_closed': "",
\   'default': "",
\   'open': "",
\   'empty': "",
\   'empty_open': "",
\   'symlink': "",
\   'symlink_open': "",
\   },
\   'lsp': {
\     'hint': "",
\     'info': "",
\     'warning': "",
\     'error': "",
\   }
\ }
" group empty folders
let g:nvim_tree_group_empty = 1
]])

require 'nvim-tree'.setup {
  disable_netrw       = false,
  hijack_netrw        = false,
  open_on_setup       = false,
  ignore_ft_on_setup  = {},
  open_on_tab         = false,
  hijack_cursor       = true,
  update_cwd          = false,
  update_to_buf_dir   = {
    enable = true,
    auto_open = true,
  },
  actions = {
    open_file = {
      window_picker = {
        exclude = {
          filetype = {
            'packer',
            'qf',
          },
          buftype = {
            'terminal',
          },
        },
      },
    },
  },
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    }
  },
  update_focused_file = {
    enable      = true,
    update_cwd  = false,
    ignore_list = {}
  },
  system_open = {
    cmd  = nil,
    args = {}
  },
  filters = {
    dotfiles = false,
    custom = { '.git', 'node_modules', '.cache' }
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 500,
  },
  view = {
    width = 40,
    height = 30,
    hide_root_folder = false,
    side = 'left',
    auto_resize = true,
    mappings = {
      custom_only = false,
      list = {}
    },
    number = false,
    relativenumber = false
  },
  trash = {
    cmd = "trash",
    require_confirm = true
  }
}


local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map('n', '<C-n>', ':NvimTreeFindFileToggle<CR>', opts)
map('n', '<leader>-r>', ':NvimTreeRefresh<CR>', opts)
map('n', '<leader>-n>', ':NvimTreeFindFile<CR>', opts)
