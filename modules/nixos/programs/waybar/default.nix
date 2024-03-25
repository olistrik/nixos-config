{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.programs.waybar;

  concatStrAttrs = sep: name: list:
    builtins.concatStringsSep sep (builtins.catAttrs name list);

  configuredModules = import ./modules.nix { inherit pkgs; };

  modulesLeft = with configuredModules; [
    workspaces
    mode
  ];

  modulesCenter = with configuredModules; [
    window
  ];

  modulesRight = with configuredModules; [
    gitlab-issues
    gitlab-merge-requests
    pulseaudio
    network
    battery
    clock
  ];

  modules = [
    ({
      name = "global";
    })
  ] ++ modulesLeft ++ modulesCenter ++ modulesRight;

  wrapNames = names: builtins.map (val: "\"${val}\"") names;
  modules2str = mods: "[${builtins.concatStringsSep ", " (wrapNames (builtins.catAttrs "name" mods))}]";



in
{
  options.olistrik.programs.waybar = basicOptions "Waybar";

  config = mkIf cfg.enable {
    programs.waybar.enable = true;

    environment.systemPackages = with pkgs; [
      waybar
      (nerdfonts.override { fonts = [ "Hermit" "JetBrainsMono" ]; })
    ] ++ builtins.concatLists (builtins.catAttrs "requires" modules);


    environment = {
      etc."xdg/waybar/style.css".source = pkgs.writeText "waybar-style" ''
        * {
          border: none;
          border-radius: 0;
          font-family: JetBrainsMono NerdFont, Helvetica, Arial, sans-serif;
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background-color: rgba(43, 48, 59, 0);
          color: white;
        }

        box.modules-left {
          margin: 0 2px;
        }

        box.modules-right {
          margin: 0 2px;
        }

        .modules-right > * > label {
          margin: 4px 2px;
          padding: 0 10px;
          background-color: rgba(43, 48, 59, 0.8);
          border-radius: 4px;
        }

        label:focus {
            background-color: black;
        }

        ${concatStrAttrs "\n" "style" modules}
      '';

      etc."xdg/waybar/config".source = pkgs.writeText "waybar-config" ''
        {
            "layer": "top", // Waybar at top layer
            "position": "top", // Waybar position (top|bottom|left|right)
            "height": 30, // Waybar height (to be removed for auto height)

            // Choose the order of the modules
            "modules-left": ${modules2str modulesLeft},
            "modules-center": ${modules2str modulesCenter},
            "modules-right": ${modules2str modulesRight},

            // Generated Module configuration
            ${concatStrAttrs "\n" "config" modules}
        }
      '';
    };
  };
}
