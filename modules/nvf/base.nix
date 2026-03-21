{
  nvf.config.base =
    { my, lib, ... }:
    let
      inherit (lib.generators) mkLuaInline;
      inherit (lib.nvim.dag) entryBefore entryAfter;
      inherit (lib.nvim.binds) mkKeymap;
    in
    {
      imports = with my.modules.nvf.config; [
        theming

        lualine
        # hlchunk
        telescope
        git
        treesitter
        autoformat
        autoindent
        minimap
        notebook-navigator

        # nix-comment-lang
      ];

      vim = {
        ui.colorizer.enable = true;
        notes.todo-comments.enable = true;

        mini = {
          ai.enable = true;
          comment.enable = true;
          surround.enable = true;
          trailspace.enable = true;
          animate = {
            enable = true;
            setupOpts = mkLuaInline /* lua */ ''
              (function()
              	local animate = require("mini.animate")
              	return {
              		scroll = {
              			timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
              			subscroll = animate.gen_subscroll.equal({
              				predicate = function(total_scroll)
              					if vim.g.mouse_scrolled then
              						vim.g.mouse_scrolled = false
              						return false
              					end
              					return total_scroll > 1
              				end,
              			}),
              		},
              	}
              end)()
            '';
          };
        };

        luaConfigRC = {
          mini-scroll-mouse-fix = entryBefore [ "pluginConfig" ] /* lua */ ''
            for _, scroll in ipairs({ "Up", "Down" }) do
            	local key = "<ScrollWheel" .. scroll .. ">"
            	vim.keymap.set("", key, function()
            		vim.g.mouse_scrolled = true
            		return key
            	end, { noremap = true, expr = true })
            end
          '';

          # TODO: This doesn't support interactive find and replace (s/foo/bar/c).
          auto-hlsearch-toggler = entryAfter [ "pluginConfig" ] /* lua */ ''
            vim.on_key(function(char)
            	if vim.fn.mode() == "n" then
            		local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
            		if vim.opt.hlsearch:get() ~= new_hlsearch then
            			if new_hlsearch or (not MiniAnimate.is_active("scroll") and not vim.g.mouse_scrolled) then
            				vim.opt.hlsearch = new_hlsearch
            			end
            		end
            	end
            end, vim.api.nvim_create_namespace("auto_hlsearch"))
          '';
        };

        utility.snacks-nvim = {
          enable = true;
          setupOpts = {
            indent = {
              enabled = true;
              animate.enabled = false;
            };
            # scroll = {
            #   enabled = true;
            # };
          };
        };

        globals.mapleader = " ";

        options = {
          number = true; # show current line number.
          relativenumber = true; # show other lines as relative numbers.
          scrolloff = 5; # keep at least 5 lines visible above/below cursor.
          incsearch = true; # show first match while searching.
          # hlsearch = false; # don't keep previous searches highlighted.
          mouse = "nvchr"; # allow mouse in all modes but insert.
          signcolumn = "yes"; # always show the sign column.
          conceallevel = 2; # allow complete concealment and character concealment.

          tm = 3000; # timeoutlen mildly frustrating this has been renamed.

          exrc = true;
        };

        keymaps = [
          (mkKeymap [ "n" "v" ] ";" ":" { })
          (mkKeymap [ "n" "v" ] ";;" ";" { noremap = false; })
        ];

        clipboard = {
          enable = true;
          registers = "unnamed,unnamedplus";
        };
      };
    };
}
