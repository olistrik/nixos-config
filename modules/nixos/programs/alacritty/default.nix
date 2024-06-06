# heavily influenced https://github.com/nix-community/home-manager/blob/a7117efb3725e6197dd95424136f79147aa35e5b/modules/programs/alacritty.nix
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.olistrik.programs.alacritty;
  mkSubModule = attrs: types.attrsOf (types.submodule attrs);
  tomlFormat = pkgs.formats.toml { };
in
{
  options.olistrik.programs.alacritty = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        enable or disable alacritty.
      '';
    };
    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      example = literalExpression ''
        {
          window.dimensions = {
            lines = 3;
            columns = 200;
          };
          keyboard.bindings = [
            {
              key = "K";
              mods = "Control";
              chars = "\\u000c";
            }
          ];
        }
      '';
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/alacritty/alacritty.yml` or
        {file}`$XDG_CONFIG_HOME/alacritty/alacritty.toml`
        (the latter being used for alacritty 0.13 and later).
        See <https://github.com/alacritty/alacritty/tree/master#configuration>
        for more info.
      '';
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
            --add-flags "--config-file /etc/alacritty/alacritty.toml"
        '';
      })
    ];

    environment.etc."alacritty/alacritty.toml" = lib.mkIf (cfg.settings != { }) {
      source = (tomlFormat.generate "alacritty.toml" cfg.settings).overrideAttrs
        (finalAttrs: prevAttrs: {
          buildCommand = lib.concatStringsSep "\n" [
            prevAttrs.buildCommand
            # TODO: why is this needed? Is there a better way to retain escape sequences?
            "substituteInPlace $out --replace '\\\\' '\\'"
          ];
        });
    };
  };
}
