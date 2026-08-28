{
  nixos.hosts.hestia =
    { lib, pkgs, ... }:
    let
      sourceUrl = "https://github.com/olistrik/nixos-config/archive/refs/heads/master.tar.gz";
      gcRootDirectory = "/nix/var/nix/gcroots/build-all-systems";
      systems = [
        "thoth"
        "hestia"
      ];
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
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            serviceConfig = {
              Type = "oneshot";
              # The service evaluates configurations independently of the
              # running NixOS evaluation, so it does not inherit
              # nixpkgs.config.allowUnfree from all-hosts.nix.
              Environment = [ "NIXPKGS_ALLOW_UNFREE=1" ];
            };
            path = with pkgs; [
              nix
              coreutils
              git
              openssh
            ];
            script = ''
              set -euo pipefail

              GC_ROOT_DIRECTORY="${gcRootDirectory}"
              SYSTEMS="${toString systems}"

              mkdir -p "$GC_ROOT_DIRECTORY"

              build_system() {
                local system="$1"
                local output
                local temporary_root

                echo "building $system..."
                output="$(
                  ${lib.getExe' pkgs.nix "nix-build"} \
                    --no-out-link \
                    --option tarball-ttl 0 \
                    --expr '
                      { host }:
                      let
                        config = import (builtins.fetchTarball {
                          url = "${sourceUrl}";
                        }) { };
                      in
                      config.hosts.''${host}.config.system.build.toplevel
                    ' \
                    --argstr host "$system"
                )"

                temporary_root="$(mktemp --tmpdir="$GC_ROOT_DIRECTORY" ".''${system}.XXXXXX")"
                ln -sfn "$output" "$temporary_root"
                mv -Tf "$temporary_root" "$GC_ROOT_DIRECTORY/$system"
                echo "pinned $system at $output"
              }

              echo "starting build of all system configurations..."
              for system in ''${SYSTEMS}; do
                build_system "$system"
              done
              echo "done!"
            '';
          };
        };
      };
    };
}
