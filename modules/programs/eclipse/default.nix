{ config, lib, pkgs, symlinkJoin, makeWrapper, ... }:

with lib;

let

  cfge = config.environment;
  cfg = config.programs.eclipse;


in {
  options = {
    programs.eclipse.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        enable or disable eclipse.
      '';
    };
  };


  config =
    mkIf cfg.enable {
      environment.systemPackages = let
        unwrapped = pkgs.eclipses.eclipseWithPlugins {
          eclipse = pkgs.eclipses.eclipse-platform;
          jvmArgs = ["-Xmx2048m"];
          plugins = with pkgs.eclipses.plugins; [
            vrapper
          ];
        };
      in
      [
        (
          pkgs.symlinkJoin {
            name = "elcipse";
            paths = [ unwrapped ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/eclipse \
                --set GTK_THEME Raleigh
            '';
          }
        )
      ];
  };
}

