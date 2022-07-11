{ pkgs, dsl, ... }:
with dsl;
let telescopeAction = action: rawLua "require('telescope.actions').${action}";
in {
  plugins = with pkgs.vimPlugins; [
    telescope-nvim
    telescope-fzy-native-nvim
    telescope-file-browser-nvim
    popup-nvim
    plenary-nvim
  ];

  environment.systemPackages = [ ripgrep fd ];

  setup.treesitter = {
    defaults = {
      mappings = {
        i = {
          "['<C-j>']" = telescopeAction "move_selection_next";
          "['<C-k>']" = telescopeAction "move_selection_previous";
        };
      };
      file_ignore_patterns = [ "^vendor/" "^%.git/" ];
    };
    pickers = {
      find_files = {
        find_command = [ "fd" "--type" "f" "--strip-cwd-prefix" ];
      };
    };

    extensions = {
      # fzf = {
      #   override_generic_sorter = true;
      #   override_file_sorter = true;
      #   case_mode = "smart_case"; # ignore_case, respect_case, smart_case
      # };

      fzy_native = {
        override_generic_sorter = true;
        override_file_sorter = true;
        case_mode = "smart_case"; # ignore_case, respect_case, smart_case
      };

      file_browser = { theme = "ivy"; };
    };
  };
}
