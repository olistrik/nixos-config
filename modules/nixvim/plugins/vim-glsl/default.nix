{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.olistrik.plugins.vim-glsl;
in
{
  options = {
    olistrik.plugins.vim-glsl = with types; {
      enable = mkEnableOption "vim-glsl";
      package = mkOption {
        type = package;
        default = pkgs.olistrik.vim-glsl;
        description = ''
          The package to use for the vim-glsl plugin.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    extraPlugins = [ cfg.package ];
    extraConfigLua = '''';
  };
}
  
