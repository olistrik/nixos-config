{ pkgs, config, lib, ... }:
let
  nmap = key: action: {
    inherit key action;
    mode = "n";
    options = {
      noremap = true;
      silent = true;
    };
  };
in
with lib;
with lib.olistrik;
with lib.olistrik.nixvim;
mkPlugin "telescope" {
  inherit config;

  keymaps = [
    (nmap "<C-p>" "<cmd>Telescope find_files<CR>")
    (nmap "<C-f>" "<cmd>Telescope live_grep<CR>")
    (nmap "<Leader><Tab>" "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>")
  ];

  plugins.telescope = {
    defaults = {
      file_ignore_patterns = [
        "^vendor/"
        "^node_modules/"
        "^.git/"
      ];
      vimgrep_arguments = [
        "${pkgs.ripgrep}/bin/rg"
        "--color=never"
        "--no-heading"
        "--with-filename"
        "--line-number"
        "--column"
        "--smart-case"
        "--trim"
      ];
    };

    extensions = {
      file_browser = {
        enable = true;
        theme = "ivy";
      };

      fzy-native = {
        enable = true;
        overrideGenericSorter = true;
        overrideFileSorter = true;
      };
    };

    extraOptions.pickers = {
      find_files = {
        find_command = [
          "${pkgs.fd}/bin/fd"
          "--type"
          "f"
          "--strip-cwd-prefix"
          "-uu"
          "--ignore-file=.vimignore"
        ];
      };
    };
  };
}
