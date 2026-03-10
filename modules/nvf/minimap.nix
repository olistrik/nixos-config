{
  nvf.config.minimap =
    { lib, ... }:
    let
      inherit (lib.generators) mkLuaInline;
      inherit (lib.nvim.binds) mkKeymap;
    in
    {
      vim = {
        mini = {
          map = {
            enable = true;
            setupOpts = mkLuaInline /* lua */ ''
              (function()
              	local map = require("mini.map")
              	return {
              		integrations = {
              			map.gen_integration.builtin_search(),
              			map.gen_integration.diagnostic(),
              			map.gen_integration.gitsigns(),
              		},
              		symbols = {
              			encode = map.gen_encode_symbols.dot("4x2"),
              		},
              		window = {
              			show_integration_count = false,
              		},
              	}
              end)()
            '';
          };
        };

        # TODO: Modify mini.map so the map is rendered relative to the active buffer (and can be ommited from others).
        # luaConfigRC = {
        #   mini-map-auto-open = entryAfter ["pluginConfig"] /* lua */ ''
        #       vim.api.nvim_create_autocmd("VimEnter", {
        #           callback = function()
        #             MiniMap.open()
        #           end,
        #         })
        #     '';
        # };

        keymaps = [
          (mkKeymap [ "n" ] "mm" "MiniMap.toggle" {
            lua = true;
            desc = "Toggle MiniMap [mini.map]";
          })
        ];
      };
    };
}
