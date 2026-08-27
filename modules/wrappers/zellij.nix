{
  wrappers.config.zellij =
    {
      my,
      config,
      pkgs,
      lib,
      wlib,
      ...
    }:
    let
      inherit (lib.lists) toList;
      bind = args: children: {
        bind = {
          _args = toList args;
          _children = toList children;
        };
      };
    in
    {
      imports = [ my.modules.wrappers.programs.zellij ];

      config = {
        settings = {
          theme = "tokyo-night-dark";
          pane_frames = false;
          keybinds._children = [
            {
              pane._children = [
                # This overbinds { ToggleFloatingPanes; SwitchToMode "Normal"; }
                (bind "w" [
                  { NewPane = "up"; }
                  { SwitchToMode = "normal"; }
                ])
                (bind "a" [
                  { NewPane = "left"; }
                  { SwitchToMode = "normal"; }
                ])
                # This overbinds { NewPane "stacked"; SwitchToMode "normal"; }
                (bind "s" [
                  { NewPane = "down"; }
                  { SwitchToMode = "normal"; }
                ])
                (bind "d" [
                  { NewPane = "right"; }
                  { SwitchToMode = "normal"; }
                ])
                (bind "Ctrl w" { SwitchToMode = "normal"; })
              ];
            }
            {
              shared_except = {
                _args = [
                  "locked"
                  "pane"
                ];
                _children = [
                  (bind "Ctrl w" { SwitchToMode = "pane"; })
                ];
              };
            }
          ];
        };
      };
    };

  wrappers.programs.zellij =
    {
      config,
      pkgs,
      lib,
      wlib,
      my,
      ...
    }:
    let
      inherit (lib) mkOption types;
    in
    {
      imports = [ wlib.modules.default ];

      options = {
        settings = mkOption {
          type = types.attrs;
          default = { };
          description = "Structured settings converted to KDL config via my.lib.generators.toKDL";
        };
        extraConfig = mkOption {
          type = types.lines;
          default = "";
          description = "Raw KDL lines appended after generated settings (escape hatch)";
        };
      };

      config = {
        package = pkgs.zellij;
        binName = "zellij";

        constructFiles.zellijConfig = {
          content = ''
            ${my.lib.generators.toKDL { } config.settings}
            ${config.extraConfig}
          '';
          relPath = "config.kdl";
        };

        flags."--config" = config.constructFiles.zellijConfig.path;
      };
    };
}
