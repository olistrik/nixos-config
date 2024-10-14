{ pkgs, ... }:
let
  flakeUri = "github:olistrik/nixos-config";
  systems = [ "thoth" "hestia" ];
in
{
  config = {
    systemd = {
      timers."build-all-systems" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "weekly"; # Monday 00:00
          AccuracySec = "10min";
        };
      };
      services."build-all-systems" = {
        serviceConfig.Type = "oneshot";
        path = with pkgs; [ nix git ];
        script = ''
          #!/bin/sh
          FLAKE_URI="${flakeUri}"
          SYSTEMS="${toString systems}"

          echo "starting build of all system configurations..."
          for system in ''${SYSTEMS}; do
            echo "building ''${system}..." 
            nix build --no-link ''${FLAKE_URI}#nixosConfigurations.''${system}.config.system.build.toplevel
          done
          echo "done!"
        '';
      };
    };
  };
}
