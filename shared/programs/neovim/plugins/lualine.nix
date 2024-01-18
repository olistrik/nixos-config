{ pkgs, lib, ... }: with lib; {
  programs.nixvim.plugins.lualine = {
    alwaysDivideMiddle = true;
    globalstatus = true;
    iconsEnabled = true;

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
