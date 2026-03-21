{
  wrappers.config.alacritty =
    {
      my,
      config,
      pkgs,
      lib,
      wlib,
      ...
    }:
    {
      imports = [ my.modules.wrappers.programs.alacritty ];

      config = {
        theme = "tokyonight_night";
        themePackage = pkgs.vimPlugins."tokyonight-nvim";
        themePath = "/extras/alacritty/";

        settings = {
          font = {
            normal.family = "JetBrainsMono NerdFont Mono";
            size = 11.5; # 11.25 causes glyphs to be off by 1px.
          };
          window.opacity = 0.95;
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
        themePath = mkOption {
          type = with types; str;
          default = "/share/alacritty-theme";
        };
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
          inherit (lib.strings) normalizePath;
          path = normalizePath "/${config.themePath}/${config.theme}.toml";
          # We want to check that the theme actually exists.
          # We need to do this at build time, to avoid IFD.
          alacrittyTheme = config.themePackage.overrideAttrs (prevAttrs: {
            name = "alacritty-theme-for-wrapper";
            postInstall =
              let
                inherit (config) theme themePath;
              in
              lib.concatStringsSep "\n" [
                (prevAttrs.postInstall or "")
                (lib.optionalString (theme != null)
                  # bash
                  ''
                    if [ ! -f "$out${path}" ]; then
                      echo "error: alacritty theme '${theme}' does not exist"
                      exit 1
                    fi
                  ''
                )
              ];
          });
          theme = "${alacrittyTheme}${path}";
        in
        lib.mkIf (config.theme != null) {
          general.import = lib.mkIf (lib.versionAtLeast config.package.version "0.14") [ theme ];
          import = lib.mkIf (lib.versionOlder config.package.version "0.14") [ theme ];
        };
    };
}
