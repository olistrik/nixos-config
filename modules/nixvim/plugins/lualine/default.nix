{ lib, config, ... }:
with lib;
with lib.olistrik;
with lib.olistrik.nixvim;
mkPlugin "lualine" {
  inherit config;

  plugins.lualine = {
    enable = true;
    settings = {
      sections = {
        lualine_a = [ "mode" ];
        lualine_b = [ "branch" "diff" "diagnostics" ];
        lualine_c = [ "filename" ];
        lualine_x = [ "encoding" "fileformat" "filetype" ];
        lualine_y = [ "location" ];
        lualine_z = [ "progress" ];
      };
      inactive_section = {
        lualine_c = [ "filename" ];
        lualine_x = [ "location" ];
      };
      options = {
        theme = "ayu_mirage";

        always_divide_middle = true;
        globalstatus = true;
        icons_enabled = true;
      };
    };

  };
}
