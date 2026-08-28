{
  nixos.hosts.hestia =
    { lib, pkgs, ... }:
    let
      repositoryUrl = "https://github.com/olistrik/nixos-config.git";
      pushUrl = "git@github.com:olistrik/nixos-config.git";
      persistentPath = "/persist/nix-cache-builder";
      statePath = "${persistentPath}/state";
      repositoryPath = "${statePath}/repository";
      signingKeyPath = "${persistentPath}/id_ed25519";
      signingPublicKeyPath = "${signingKeyPath}.pub";
      homewireKeyPath = "${persistentPath}/homewire_id_ed25519";
      systems = [
        "thoth"
        "hestia"
      ];

      # Only these identities may introduce arbitrary configuration changes.
      # Their private keys remain on Oli's own devices.
      userAllowedSigners = pkgs.writeText "nix-cache-user-allowed-signers" ''
        oliverstrik@gmail.com namespaces="git" sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMcvHSxN1mFGgB6r19eHIqGKvhNOwddvVe43NwhKHmWzAAAABHNzaDo=
        oliverstrik@gmail.com namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHwyuoI18ZEoo/c38XvI6HwvRlxigxd3lPzshi7RtVw2
      '';

      # Published by GitHub at https://api.github.com/meta. Pinning this avoids
      # trusting an SSH host key obtained during the first automated push.
      githubKnownHosts = pkgs.writeText "github-known-hosts" ''
        github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
      '';

      # Verify either a normal commit signed by Oli or a pin-only commit signed
      # by Hestia. The latter key is deliberately loaded from /persist rather
      # than stored, even encrypted, in this repository.
      verifyCommit = pkgs.writeShellScript "verify-cache-builder-commit" ''
        set -euo pipefail

        repository="$1"
        commit="$2"
        bot_allowed_signers="$(mktemp)"
        trap 'rm -f "$bot_allowed_signers"' EXIT

        if ! ${lib.getExe' pkgs.openssh "ssh-keygen"} -l -f ${signingPublicKeyPath} >/dev/null; then
          echo "invalid Hestia signing public key: ${signingPublicKeyPath}" >&2
          exit 1
        fi

        read -r key_type key_material _ <${signingPublicKeyPath}
        printf 'nix-cache-builder@hestia namespaces="git" %s %s\n' \
          "$key_type" "$key_material" >"$bot_allowed_signers"

        git_verify() {
          ${lib.getExe pkgs.git} \
            -c safe.directory="$repository" \
            -C "$repository" \
            -c gpg.format=ssh \
            -c gpg.ssh.allowedSignersFile="$1" \
            verify-commit "$commit" >/dev/null 2>&1
        }

        validate_pin_only_commit() {
          local parent_line
          local changed

          parent_line="$(${lib.getExe pkgs.git} -c safe.directory="$repository" -C "$repository" rev-list --parents -n 1 "$commit")"
          if [[ "$(wc -w <<<"$parent_line")" -ne 2 ]]; then
            echo "refusing bot commit without exactly one parent: $commit" >&2
            return 1
          fi

          while IFS= read -r changed; do
            case "$changed" in
              npins/sources.json|npins/default.nix) ;;
              *)
                echo "refusing non-npins path in bot commit $commit: $changed" >&2
                return 1
                ;;
            esac
          done < <(${lib.getExe pkgs.git} -c safe.directory="$repository" -C "$repository" diff-tree --no-commit-id --name-only -r "$commit")
        }

        if git_verify ${userAllowedSigners}; then
          exit 0
        fi

        if git_verify "$bot_allowed_signers"; then
          validate_pin_only_commit
          exit 0
        fi

        echo "refusing master tip without an authorized SSH signature: $commit" >&2
        exit 1
      '';

      commonHardening = {
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        UMask = "0007";
      };
    in
    {
      users = {
        groups.nix-cache-automation = { };
        users = {
          nix-cache-builder = {
            isSystemUser = true;
            group = "nix-cache-automation";
            home = statePath;
          };
          nix-cache-publisher = {
            isSystemUser = true;
            group = "nix-cache-automation";
            home = statePath;
          };
        };
      };

      systemd = {
        tmpfiles.rules = [
          "d ${persistentPath} 0755 root root -"
          "d ${statePath} 0770 nix-cache-builder nix-cache-automation -"
          "d ${statePath}/.ssh 0700 nix-cache-builder nix-cache-automation -"
          "L+ ${statePath}/.ssh/known_hosts - - - - ${githubKnownHosts}"
        ];

        timers."build-all-systems" = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "weekly"; # Monday 00:00
            AccuracySec = "10min";
            Persistent = true;
          };
        };

        services = {
          "build-all-systems" = {
            description = "Update trusted npins and build all NixOS systems";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            unitConfig.OnSuccess = "build-all-systems-publish.service";
            serviceConfig = commonHardening // {
              Type = "oneshot";
              User = "nix-cache-builder";
              Group = "nix-cache-automation";
              InaccessiblePaths = [ "-${signingKeyPath}" ];
              LoadCredential = "homewire-key:${homewireKeyPath}";
              ReadWritePaths = [ statePath ];
              Environment = [
                "HOME=${statePath}"
                "NIXPKGS_ALLOW_UNFREE=1"
              ];
            };
            path = with pkgs; [
              bash
              coreutils
              git
              nix
              npins
              openssh
            ];
            script = ''
              set -euo pipefail

              REPOSITORY=${repositoryPath}
              LAST_ACCEPTED=${statePath}/last-accepted-commit
              PUBLISH_REQUEST=${statePath}/publish-request
              GC_ROOT_DIRECTORY=${statePath}/gcroots
              HOMEWIRE_KEY="$CREDENTIALS_DIRECTORY/homewire-key"

              export GIT_SSH_COMMAND='${lib.getExe pkgs.openssh} -i '"$HOMEWIRE_KEY"' -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile=${githubKnownHosts}'
              # npins 0.4.1 does not propagate GIT_SSH_COMMAND to git
              # ls-remote. Make the systemd credential its conventional SSH
              # identity for this service invocation as well.
              ln -sfn "$HOMEWIRE_KEY" "$HOME/.ssh/id_ed25519"
              trap 'rm -f "$HOME/.ssh/id_ed25519"' EXIT

              rm -f "$PUBLISH_REQUEST"
              mkdir -p "$GC_ROOT_DIRECTORY"

              if [[ ! -d "$REPOSITORY/.git" ]]; then
                git clone --no-checkout ${repositoryUrl} "$REPOSITORY"
              fi

              git -C "$REPOSITORY" remote set-url origin ${repositoryUrl}
              git -C "$REPOSITORY" fetch --prune origin \
                +refs/heads/master:refs/remotes/origin/master

              TIP="$(git -C "$REPOSITORY" rev-parse refs/remotes/origin/master)"
              ${verifyCommit} "$REPOSITORY" "$TIP"

              if [[ -s "$LAST_ACCEPTED" ]]; then
                PREVIOUS="$(<"$LAST_ACCEPTED")"
                if ! git -C "$REPOSITORY" merge-base --is-ancestor "$PREVIOUS" "$TIP"; then
                  echo "refusing master rollback: $TIP does not descend from $PREVIOUS" >&2
                  exit 1
                fi
              fi

              git -C "$REPOSITORY" reset --hard "$TIP"
              git -C "$REPOSITORY" clean -fdx

              npins --directory "$REPOSITORY/npins" upgrade
              npins --directory "$REPOSITORY/npins" update

              while IFS= read -r changed; do
                case "$changed" in
                  npins/sources.json|npins/default.nix) ;;
                  *)
                    echo "npins modified an unexpected path: $changed" >&2
                    exit 1
                    ;;
                esac
              done < <(git -C "$REPOSITORY" status --short | sed 's/^...//')

              build_system() {
                local system="$1"
                local output

                echo "building $system from verified commit $TIP with updated pins..."
                output="$(
                  nix-build \
                    --no-out-link \
                    --option tarball-ttl 0 \
                    --expr '
                      { host, source }:
                      let
                        config = import (builtins.toPath source) { };
                      in
                      config.hosts.''${host}.config.system.build.toplevel
                    ' \
                    --argstr host "$system" \
                    --argstr source "$REPOSITORY"
                )"

                nix-store \
                  --add-root "$GC_ROOT_DIRECTORY/$system" \
                  --indirect \
                  --realise "$output" >/dev/null
                echo "pinned $system at $output"
              }

              for system in ${toString systems}; do
                build_system "$system"
              done

              if git -C "$REPOSITORY" diff --quiet -- npins; then
                printf '%s\n' "$TIP" >"$LAST_ACCEPTED"
                echo "pins are already current; nothing to publish"
                exit 0
              fi

              DIFF_HASH="$(git -C "$REPOSITORY" diff --binary HEAD -- npins | sha256sum | cut -d' ' -f1)"
              printf '%s %s\n' "$TIP" "$DIFF_HASH" >"$PUBLISH_REQUEST"
              echo "builds succeeded; queued pin update for signed publication"
            '';
          };

          "build-all-systems-publish" = {
            description = "Sign and publish a successfully built npins update";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            serviceConfig = commonHardening // {
              Type = "oneshot";
              User = "nix-cache-publisher";
              Group = "nix-cache-automation";
              LoadCredential = "ssh-key:${signingKeyPath}";
              ReadWritePaths = [ statePath ];
              Environment = [ "HOME=${statePath}" ];
            };
            path = with pkgs; [
              coreutils
              git
              openssh
            ];
            script = ''
              set -euo pipefail

              REPOSITORY=${repositoryPath}
              LAST_ACCEPTED=${statePath}/last-accepted-commit
              PUBLISH_REQUEST=${statePath}/publish-request
              SIGNING_KEY="$CREDENTIALS_DIRECTORY/ssh-key"

              git_safe() {
                git -c safe.directory="$REPOSITORY" -C "$REPOSITORY" "$@"
              }

              if [[ ! -s "$PUBLISH_REQUEST" ]]; then
                echo "no successfully built update is awaiting publication"
                exit 0
              fi

              read -r BASE EXPECTED_DIFF_HASH <"$PUBLISH_REQUEST"
              test "$(git_safe rev-parse HEAD)" = "$BASE"
              ${verifyCommit} "$REPOSITORY" "$BASE"

              ACTUAL_DIFF_HASH="$(git_safe diff --binary HEAD -- npins | sha256sum | cut -d' ' -f1)"
              if [[ "$ACTUAL_DIFF_HASH" != "$EXPECTED_DIFF_HASH" ]]; then
                echo "refusing to publish a pin diff changed after the successful builds" >&2
                exit 1
              fi

              while IFS= read -r changed; do
                case "$changed" in
                  npins/sources.json|npins/default.nix) ;;
                  *)
                    echo "refusing unexpected publication path: $changed" >&2
                    exit 1
                    ;;
                esac
              done < <(git_safe status --short | sed 's/^...//')

              git_safe add -- npins/sources.json npins/default.nix
              git \
                -c safe.directory="$REPOSITORY" \
                -C "$REPOSITORY" \
                -c core.hooksPath=/dev/null \
                -c gpg.format=ssh \
                -c gpg.ssh.program=${lib.getExe' pkgs.openssh "ssh-keygen"} \
                -c user.name=Hestia \
                -c user.email=nix-cache-builder@hestia \
                -c user.signingKey="$SIGNING_KEY" \
                commit -S -m 'chore: update npins'

              COMMIT="$(git_safe rev-parse HEAD)"
              ${verifyCommit} "$REPOSITORY" "$COMMIT"

              export GIT_SSH_COMMAND='${lib.getExe pkgs.openssh} -i '"$SIGNING_KEY"' -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile=${githubKnownHosts}'
              git_safe push ${pushUrl} HEAD:refs/heads/master

              printf '%s\n' "$COMMIT" >"$LAST_ACCEPTED"
              rm -f "$PUBLISH_REQUEST"
              echo "published signed pin update $COMMIT"
            '';
          };
        };
      };
    };
}
