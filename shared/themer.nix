{config, lib, pkgs, ...}: 
let
  cfg = config.system.themer;
in
with lib; {
  imports = [];
  options = {
    system.themer = {
      theme = mkOption {
        type = types.attrs;
        default = {
          primary = {
            background = "#1d1f21";
            foreground = "#c5c8c6";
          };
          cursor = {
            text = "#000000";
            cursor = "#ffffff";
          };
          selection = {
            text = "#eaeaea";
            background = "#404040";
          };
          normal = {
            black = "#1d1f21";
            red = "#cc6666";
            green = "#b5bd68";
            yellow = "#f0c678";
            blue = "#81a2be";
            magenta = "#b294bb";
            cyan = "#8abeb7";
            white = "#c5c8c6";
          };
          bright = {
            black = "#666666";
            red = "#d54e53";
            green = "#b9ac4a";
            yellow = "#e7c547";
            blue = "#7aa6da";
            magenta = "#c397d8";
            cyan = "#70c0b1";
            white = "#eaeaea";
          };
        };
      };
      wm = {
        gaps = {
          inner = mkOption {
            type = types.int;
            default = 10;
            description =  ''
              The gap between windows (and the edge apparently).
            '';
          };
          outer = mkOption {
            type = types.int;
            default = -5;
            description =  ''
              The gap between windows and the edge (but not eachother).
            '';
          };
        };
      };
    };
  };
  config  = {};
}
