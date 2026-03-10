{
  wrappers.my.alacritty =
    {
      self,
      config,
      pkgs,
      lib,
      wlib,
      ...
    }:
    {
      imports = [ self.modules.wrappers.programs.alacritty ];

      config = {
        theme = "tokyo_night";

        settings = {
          font.normal.family = "JetBrainsMono NerdFont";
          window.opacity = 0.95;
          colors = lib.mkIf (config.theme == null) {
            # Ayu mirage theme
            primary = {
              background = "#212733";
              foreground = "#d9d7ce";
            };

            cursor = {
              cursor = "#ffcc66";
              text = "#212733";
            };

            selection = {
              text = "#d9d7ce";
              background = "#343f4c";
            };

            normal = {
              black = "#212733";
              red = "#ed8274";
              green = "#a6cc70";
              yellow = "#fad07b";
              blue = "#6dcbfa";
              magenta = "#cfbafa";
              cyan = "#90e1c6";
              white = "#5c6773";
            };

            bright = {
              black = "#607080";
              red = "#ff3333";
              green = "#bbe67e";
              yellow = "#ffcc66";
              blue = "#5ccfe6";
              magenta = "#d4bfff";
              cyan = "#95e6cb";
              white = "#ffffff";
            };
          };
        };
      };
    };

  # shamelessly ported from https://github.com/nix-community/home-manager/blob/master/modules/programs/alacritty.nix
  wrappers.programs.alacritty =
    {
      config,
      pkgs,
      lib,
      wlib,
      ...
    }:
    let
      inherit (lib) mkOption mkPackageOption types;
    in
    {
      imports = [ wlib.wrapperModules.alacritty ];

      options = {
        themePackage = mkPackageOption pkgs "alacritty-theme" { };
        theme = mkOption {
          type = with types; nullOr str;
          default = null;
          example = "solarized_dark";
        };
        description = ''
          A theme from the
          [alacritty-theme](https://github.com/alacritty/alacritty-theme)
          repository to import in the configuration.
          See <https://github.com/alacritty/alacritty-theme/tree/master/themes>
          for a list of available themes.
          If you would like to import your own theme, use
          {option}`programs.alacritty.settings.general.import` or
          {option}`programs.alacritty.settings.colors` directly.
        '';
      };

      config.settings =
        let
          # We want to check that the theme actually exists.
          # We need to do this at build time, to avoid IFD.
          alacrittyTheme = config.themePackage.overrideAttrs (prevAttrs: {
            name = "alacritty-theme-for-wrapper";
            postInstall =
              let
                inherit (config) theme;
              in
              lib.concatStringsSep "\n" [
                (prevAttrs.postInstall or "")
                (lib.optionalString (theme != null)
                  # bash
                  ''
                    if [ ! -f "$out/share/alacritty-theme/${theme}.toml" ]; then
                      echo "error: alacritty theme '${theme}' does not exist"
                      exit 1
                    fi
                  ''
                )
              ];
          });
          theme = "${alacrittyTheme}/share/alacritty-theme/${config.theme}.toml";
        in
        lib.mkIf (config.theme != null) {
          general.import = lib.mkIf (lib.versionAtLeast config.package.version "0.14") [ theme ];
          import = lib.mkIf (lib.versionOlder config.package.version "0.14") [ theme ];
        };
    };
}
