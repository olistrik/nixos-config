{
  nvf.config.codecompanion =
    {
      lib,
      config,
      options,
      ...
    }:
    let
      inherit (lib.generators) mkLuaInline;
      inherit (lib.nvim.binds) mkMappingOption mkKeymap;

      cfg = config.vim.assistant.codecompanion-nvim;
      keys = cfg.mappings;
      inherit (options.vim.assistant.codecompanion-nvim) mappings;
    in
    {
      options.vim.assistant.codecompanion-nvim = {
        mappings = {
          actions = mkMappingOption "Actions menu [CodeCompanion]" "<leader>ca";
          toggleChat = mkMappingOption "Toggle chat window [CodeCompanion]" "<leader>cc";
          addSelection = mkMappingOption "Add visual selection to chat [CodeCompanion]" "<leader>cy";
        };
      };

      config.vim = {
        assistant.codecompanion-nvim = {
          enable = true;

          setupOpts = mkLuaInline /* lua */ ''
            {
              adapters = {
                acp = {
                  copilot_cli = function()
                    local helpers = require("codecompanion.adapters.acp.helpers")
                    ---@class CodeCompanion.ACPAdapter.CopilotCLI: CodeCompanion.ACPAdapter
                    return {
                      name = "copilot_cli",
                      formatted_name = "Copilot CLI",
                      type = "acp",
                      roles = {
                        llm = "assistant",
                        user = "user",
                      },
                      opts = {
                        vision = true,
                      },
                      commands = {
                        default = {"copilot", "--acp", "--stdio"},
                      },
                      defaults = {
                        mcpServers = {},
                        timeout = 20000,
                      },
                      parameters = {
                        protocolVersion = 1,
                        clientCapabilities = {
                          fs = { readTextFile = true, writeTextFile = true },
                        },
                        clientInfo = {
                          name = "CodeCompanion.nvim",
                          version = "1.0.0",
                        },
                      },
                      handlers = {
                        setup = function(self)
                          return true
                        end,
                        form_messages = function(self, messages, capabilities)
                          return helpers.form_messages(self, messages, capabilities)
                        end,
                        on_exit = function(self, code) end,
                      },
                    }
                  end
                },
              },
              interactions = {
                chat = {
                  -- adapter = "copilot_cli",
                  adapter = "opencode",
                },
              },
              display = {
                chat = {
                  -- show_settings = true,
                  start_in_insert_mode = true,
                  show_header_seperator = true,
                },
              },
            }
          '';
        };
        lazy.plugins.codecompanion-nvim = {
          cmd = "CodeCompanionChat";
          keys = [
            (mkKeymap [ "n" "v" ] keys.actions "<cmd>CodeCompanionActions<cr>" {
              desc = mappings.actions.description;
            })
            (mkKeymap [ "n" "v" ] keys.toggleChat "<cmd>CodeCompanionChat Toggle<cr>" {
              desc = mappings.toggleChat.description;
            })
            (mkKeymap [ "v" ] keys.addSelection "<cmd>CodeCompanionChat Add<cr>" {
              desc = mappings.addSelection.description;
            })
          ];
        };
      };
    };

  nvf.config.keymaps = {
  };
}
