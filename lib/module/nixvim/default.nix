{ lib, ... }:
with lib;
let
  _mk = kind: name: ({ config, options ? { }, ... }@args:
    let
      cfg = config.olistrik."${kind}s".${name};
    in
    {
      options.olistrik."${kind}s".${name} = {
        enable = mkEnableOption "enable the ${name} ${kind}";
      } // options;
      config = mkIf cfg.enable
        (removeAttrs args [ "config" "options" ]);
    });
in
{
  nixvim = {
    mkPlugin = _mk "plugin";
    mkPreset = _mk "preset";
  };
}

