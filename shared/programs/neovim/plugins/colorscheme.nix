{ pkgs, lib, ... }: {
  programs.nixvim = {
    colorschemes.ayu = {
      extraOptions = {
        mirage = true;
      };
    };
    plugins.lualine.theme = "ayu_mirage";
  };
}
