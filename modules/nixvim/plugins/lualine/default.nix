{ lib, config, ... }:
with lib;
with lib.olistrik;
with lib.olistrik.nixvim;
mkPlugin "lualine" {
  inherit config;

  plugins.lualine = {
    enable = true;
    alwaysDivideMiddle = true;
    globalstatus = true;
    iconsEnabled = true;

    theme = "ayu_mirage";

    sections = {
      lualine_a = [ "mode" ];
      lualine_b = [ "branch" "diff" "diagnostics" ];
      lualine_c = [ "filename" ];
      lualine_x = [ "encoding" "fileformat" "filetype" ];
      lualine_y = [ "location" ];
      lualine_z = [ "progress" ];
    };

    inactiveSections = {
      lualine_c = [ "filename" ];
      lualine_x = [ "location" ];
    };
  };
}
