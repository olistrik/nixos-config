## configuration module for alacritty

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
        colors = {
          primary = {
            background = mkOption {
              type = types.str;
              default = "#1d1f21";
              description = ''
                the background color.
              '';
            };
            foreground = mkOption {
              type = types.str;
              default = "#c5c8c6";
              description = ''
                the foreground color.
              '';
            };
          };
          normal = {
            black = mkOption {
              type = types.str;
              default = "#1d1f21";
              description = ''
                The normal black color.
              '';
            };
            red = mkOption {
              type = types.str;
              default = "#cc6666";
              description = ''
                The normal red color.
              '';
            };
            green = mkOption {
              type = types.str;
              default = "#b5bd68";
              description = ''
                The normal green color.
              '';
            };
            yellow = mkOption {
              type = types.str;
              default = "#f0c678";
              description = ''
                The normal yellow color.
              '';
            };
            blue = mkOption {
              type = types.str;
              default = "#81a2be";
              description = ''
                The normal blue color.
              '';
            };
            magenta = mkOption {
              type = types.str;
              default = "#b294bb";
              description = ''
                The normal magenta color.
              '';
            };
            cyan = mkOption {
              type = types.str;
              default = "#8abeb7";
              description = ''
                The normal cyan color.
              '';
            };
            white = mkOption {
              type = types.str;
              default = "#c5c8c6";
              description = ''
                The normal white color.
              '';
            };
          };
          bright = {
            black = mkOption {
              type = types.str;
              default = "#666666";
              description = ''
                The bright black color.
              '';
            };
            red = mkOption {
              type = types.str;
              default = "#d54e53";
              description = ''
                The bright red color.
              '';
            };
            green = mkOption {
              type = types.str;
              default = "#b9ac4a";
              description = ''
                The bright green color.
              '';
            };
            yellow = mkOption {
              type = types.str;
              default = "#e7c547";
              description = ''
                The bright yellow color.
              '';
            };
            blue = mkOption {
              type = types.str;
              default = "#7aa6da";
              description = ''
                The bright blue color.
              '';
            };
            magenta = mkOption {
              type = types.str;
              default = "#c397d8";
              description = ''
                The bright magenta color.
              '';
            };
            cyan = mkOption {
              type = types.str;
              default = "#70c0b1";
              description = ''
                The bright cyan color.
              '';
            };
            white = mkOption {
              type = types.str;
              default = "#eaeaea";
              description = ''
                The bright white color.
              '';
            };
          };
        };
      };
    };

    config = mkIf cfg.enable {
      system.activationScripts.alacritty = ''
        for d in $(grep -v "nologin" /etc/passwd | cut -d: -f6); do
        if [ ! -e ''${d}/.config/alacritty/alacritty.yml ]; then
          mkdir -p ~/.config/alacritty
          ln -s /etc/alacritty/alacritty.yml ''${d}/.config/alacritty/alacritty.yml
        fi
        done
      '';
      environment.systemPackages = with pkgs; [ alacritty ];
      environment.etc."alacritty/alacritty.yml".text = ''
      #Font configuration
        font:
        normal:
          family: "${cfg.font.normal.family}"
          style: ${cfg.font.normal.style}
        size: ${cfg.font.size}
        draw_bold_text_with_bright_colors: ${builtins.toString cfg.brightBold}
        colors:
        primary:
          background: '${cfg.colors.primary.background}'
          foreground: '${cfg.colors.primary.foreground}'
        normal:
          black:   '${cfg.colors.normal.black}'
          red:     '${cfg.colors.normal.red}'
          green:   '${cfg.colors.normal.green}'
          yellow:  '${cfg.colors.normal.yellow}'
          blue:    '${cfg.colors.normal.blue}'
          magenta: '${cfg.colors.normal.magenta}'
          cyan:    '${cfg.colors.normal.cyan}'
          white:   '${cfg.colors.normal.white}'
        bright:
          black:   '${cfg.colors.bright.black}'
          red:     '${cfg.colors.bright.red}'
          green:   '${cfg.colors.bright.green}'
          yellow:  '${cfg.colors.bright.yellow}'
          blue:    '${cfg.colors.bright.blue}'
          magenta: '${cfg.colors.bright.magenta}'
          cyan:    '${cfg.colors.bright.cyan}'
          white:   '${cfg.colors.bright.white}'
      '';
    };
  }
