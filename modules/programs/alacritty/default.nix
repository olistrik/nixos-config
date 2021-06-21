{config, lib, pkgs, ...}:

with lib;

let

  cfge = config.environment;

  cfg = config.programs.alacritty;

in

  {
    options = {

      programs.alacritty = {

        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            enable or disable alacritty.
          '';
        };

        font = {
          normal = {
            family = mkOption {
              type = types.str;
              default = "monospace";
              description = ''
                Sets the font used by alacritty.
                Make sure it is accepted by fc-match.
              '';
            };

            style = mkOption {
              type = types.str;
              default = "Regular";
              description = ''
                Can be used to pick a specific face.
              '';
            };
          };

          size = mkOption {
            type = types.str;
            default = "11.0";
            description = ''
              The point size of the font.
            '';
          };
        };

        brightBold = mkOption {
          type = types.bool;
          default = false;
          description = ''
            If true, bold text is drawn using the bright color variants.
          '';
        };
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
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages = [
        (pkgs.symlinkJoin {
          name = "alacritty";
          paths = [ pkgs.alacritty ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/alacritty \
              --add-flags "--config-file /etc/alacritty/alacritty.yml"
          '';
        })
      ];
      environment.etc."alacritty/alacritty.yml".text = ''
      #Font configuration
        font:
          normal:
            family: "${cfg.font.normal.family}"
            style: ${cfg.font.normal.style}
          size: ${cfg.font.size}
        draw_bold_text_with_bright_colors: ${if cfg.brightBold then "true" else
        "false"}
        colors:
          primary:
            background: '${cfg.theme.primary.background}'
            foreground: '${cfg.theme.primary.foreground}'
          cursor:
            text:    '${cfg.theme.cursor.text}'
            cursor:  '${cfg.theme.cursor.cursor}'
          selection:
            text:        '${cfg.theme.selection.text}'
            background:  '${cfg.theme.selection.background}'
          normal:
            black:   '${cfg.theme.normal.black}'
            red:     '${cfg.theme.normal.red}'
            green:   '${cfg.theme.normal.green}'
            yellow:  '${cfg.theme.normal.yellow}'
            blue:    '${cfg.theme.normal.blue}'
            magenta: '${cfg.theme.normal.magenta}'
            cyan:    '${cfg.theme.normal.cyan}'
            white:   '${cfg.theme.normal.white}'
          bright:
            black:   '${cfg.theme.bright.black}'
            red:     '${cfg.theme.bright.red}'
            green:   '${cfg.theme.bright.green}'
            yellow:  '${cfg.theme.bright.yellow}'
            blue:    '${cfg.theme.bright.blue}'
            magenta: '${cfg.theme.bright.magenta}'
            cyan:    '${cfg.theme.bright.cyan}'
            white:   '${cfg.theme.bright.white}'
      '';
    };
  }
