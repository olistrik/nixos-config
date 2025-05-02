{ pkgs, jq, curl, xdg-utils, ... }:
pkgs.writeShellApplication {
  name = "waybar-gitlab";

  runtimeInputs = [ jq curl xdg-utils ];

  text = builtins.readFile ./waybar-gitlab.sh;
}

