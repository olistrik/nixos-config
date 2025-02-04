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
let
  cfg = config.olistrik.telescope;
in
{
  options.olistrik.telescope = {
    enable = mkEnableOption "telescope config";
  };
  config = mkIf cfg.enable {

    keymaps = [
      (nmap "<C-p>" "<cmd>Telescope find_files<CR>")
      (nmap "<C-f>" "<cmd>Telescope live_grep<CR>")
      (nmap "<Leader><Tab>" "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>")
    ];

    plugins.telescope = {
      settings = {
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
        pickers = {
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

      extensions = {
        file-browser = {
          enable = true;
          settings = {
            theme = "ivy";
          };
        };

        fzy-native = {
          enable = true;
          settings = {
            override_generic_sorter = true;
            override_file_sorter = true;
          };
        };
      };
    };
  };
}
