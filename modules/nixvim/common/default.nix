{ config, lib, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.common;
  autoCmd = {
    indentOverride = pattern: expandTab: spaces: {
      inherit pattern;
      event = [ "FileType" ];
      command = lib.concatStringsSep " " [
        "setlocal"
        "tabstop=${toString spaces}"
        "softtabstop=${toString spaces}"
        "shiftwidth=${toString spaces}"
        (if expandTab then "expandtab" else "noexpandtab")
      ];
    };
  };
in
{
  options.olistrik.common = {
    enable = mkEnableOption "common config";
  };

  config = mkIf cfg.enable {
    plugins = {
      # Visual aids.
      nvim-colorizer = enabled; # does this: #FF0
      todo-comments = enabled; # NOTE: Does this.

      # Commenting utilities.
      comment = enabled;

      # Brackets? Parentheses? XML Tags? Stuff for that.
      vim-surround = enabled;
      nvim-autopairs = enabled;

      # Pretty <leader>rn windows.
      dressing = {
        enable = true;
        settings = {
          input = {
            insert_only = false;
          };
        };
      };

      # luasnip = enabled;
      # harpoon = enabled;
      # abolish = enabled;
      # easy-align = enabled;
      # vim-repeat = enabled;
    };

    ## Misc stuff below.

    colorschemes.ayu = {
      enable = true;
      settings.mirage = true;
    };

    # BUG: Doesn't seem to always work. LSP getting in the way?
    editorconfig.enable = true;

    # merge wayland and nvim clipboards.
    clipboard = {
      register = [ "unnamed" "unnamedplus" ];
      providers.wl-copy.enable = true;
    };

    globals.mapleader = " ";

    opts = {
      number = true;
      relativenumber = true;
      laststatus = 1;
      scrolloff = 5;
      incsearch = true;
      hlsearch = false;
      mouse = "nvchr";
      signcolumn = "yes";

      # TODO: Tabs for indentation, spaces for alignent.
      expandtab = false;
      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 4;
    };

    autoCmd = with autoCmd; [
      (indentOverride [ "nix" ] true 2)
    ];
  };

}
