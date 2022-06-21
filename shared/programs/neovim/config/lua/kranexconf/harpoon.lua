require("harpoon").setup({
    -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
    save_on_toggle = false,

    -- saves the harpoon file upon every change. disabling is unrecommended.
    save_on_change = true,

    -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
    enter_on_sendcmd = false,

    -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
    tmux_autoclose_windows = false,

    -- filetypes that you want to prevent from adding to the harpoon list menu.
    excluded_filetypes = { "harpoon" }
})

local map = vim.api.nvim_set_keymap
local opt = { noremap = true, silent = true }

map('n', 'gm', '<cmd>lua require("harpoon.mark").add_file()<CR>', opt)
map('n', '<M-m>', '<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>', opt)
map('n', '<M-j>', '<cmd>lua require("harpoon.ui").nav_file(1)<CR>', opt)
map('n', '<M-k>', '<cmd>lua require("harpoon.ui").nav_file(2)<CR>', opt)
map('n', '<M-l>', '<cmd>lua require("harpoon.ui").nav_file(3)<CR>', opt)
map('n', '<M-;>', '<cmd>lua require("harpoon.ui").nav_file(4)<CR>', opt)
