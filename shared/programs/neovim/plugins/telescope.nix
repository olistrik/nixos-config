{ pkgs, config, lib, ... }:
let
  telescope = config.programs.nixvim.plugins.telescope;
  nmap = key: action: {
    inherit key action;
    mode = "n";
    options = {
      noremap = true;
      silent = true;
    };
  };
in
with lib; {
  programs.nixvim = {
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
          enable = mkIf telescope.enable true;
          theme = "ivy";
        };

        fzy-native = {
          enable = mkIf telescope.enable true;
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
    keymaps = mkIf telescope.enable [
      (nmap "<C-p>" "<cmd>Telescope find_files<CR>")
      (nmap "<C-f>" "<cmd>Telescope live_grep<CR>")
      (nmap "<Leader><Tab>" "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>")
    ];
  };
}
