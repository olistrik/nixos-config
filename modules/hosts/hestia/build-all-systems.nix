{
  nixos.hosts.hestia =
    { lib, pkgs, config, ... }:
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

      # This is the system-wide Git SSH trust policy, declared in
      # collections/all-hosts.nix. Its private keys remain on Oli's devices.
      userAllowedSigners = config.environment.etc."git/allowed_signers".source;

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
        mode="''${3:-}"
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

        if [[ "$mode" != "--require-bot" ]] && git_verify ${userAllowedSigners}; then
          exit 0
        fi

        if git_verify "$bot_allowed_signers"; then
          validate_pin_only_commit
          exit 0
        fi

        echo "refusing commit without an authorized SSH signature: $commit" >&2
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
          nix-cache-notifier = {
            isSystemUser = true;
            group = "nix-cache-automation";
            extraGroups = [ "msmtp" ];
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

        timers."build-all-systems-notify" = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "Mon *-*-* 08:00:00";
            AccuracySec = "5min";
            Persistent = true;
          };
        };

        services = {
          "build-all-systems" = {
            description = "Update trusted npins and build all NixOS systems";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            unitConfig = {
              OnSuccess = "build-all-systems-publish.service";
              OnFailure = "build-all-systems-publish.service";
            };
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
              curl
              gawk
              git
              jq
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
              LOG_DIRECTORY=${statePath}/logs
              SUMMARY_FILE=${statePath}/last-run-summary
              STATUS_FILE=${statePath}/last-run-status
              HOMEWIRE_KEY="$CREDENTIALS_DIRECTORY/homewire-key"

              export GIT_SSH_COMMAND='${lib.getExe pkgs.openssh} -i '"$HOMEWIRE_KEY"' -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile=${githubKnownHosts}'
              # npins 0.4.1 does not propagate GIT_SSH_COMMAND to git
              # ls-remote. Make the systemd credential its conventional SSH
              # identity for this service invocation as well.
              ln -sfn "$HOMEWIRE_KEY" "$HOME/.ssh/id_ed25519"
              trap 'rm -f "$HOME/.ssh/id_ed25519"' EXIT

              rm -f "$PUBLISH_REQUEST"
              mkdir -p "$GC_ROOT_DIRECTORY" "$LOG_DIRECTORY"
              rm -f "$LOG_DIRECTORY"/*.log

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

              OLD_PINS="$(cat "$REPOSITORY/npins/sources.json")"

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

              NEW_PINS="$(cat "$REPOSITORY/npins/sources.json")"

              # Best-effort: GitHub gives us a commit date for a revision pin.
              # Anything else (a non-GitHub source, or a rate-limited/offline
              # lookup) just falls back to showing the bare revisions.
              commit_date() {
                local owner="$1" repo="$2" rev="$3"
                curl -fsSL "https://api.github.com/repos/$owner/$repo/commits/$rev" \
                  | jq -r '.commit.committer.date // empty' \
                  | cut -dT -f1
              }

              CHANGED_PINS="$(
                jq -n --argjson old "$OLD_PINS" --argjson new "$NEW_PINS" '
                  ($old.pins // {}) as $o
                  | ($new.pins // {}) as $n
                  | [ $n | keys[] as $name
                      | select($o[$name] != null)
                      | select($o[$name].revision != $n[$name].revision)
                      | {
                          name: $name,
                          oldRevision: $o[$name].revision,
                          newRevision: $n[$name].revision,
                          oldVersion: ($o[$name].version // null),
                          newVersion: ($n[$name].version // null),
                          owner: ($n[$name].repository.owner // null),
                          repo: ($n[$name].repository.repo // null),
                          isGitHub: (($n[$name].repository.type // "") == "GitHub")
                        }
                    ]
                '
              )"

              PINS_SUMMARY=""
              while IFS= read -r entry; do
                name="$(jq -r '.name' <<<"$entry")"
                oldVersion="$(jq -r '.oldVersion' <<<"$entry")"
                newVersion="$(jq -r '.newVersion' <<<"$entry")"

                if [[ "$oldVersion" != "null" && "$newVersion" != "null" && "$oldVersion" != "$newVersion" ]]; then
                  PINS_SUMMARY+="    $name: $oldVersion -> $newVersion"$'\n'
                  continue
                fi

                oldRevision="$(jq -r '.oldRevision' <<<"$entry")"
                newRevision="$(jq -r '.newRevision' <<<"$entry")"
                oldShort="''${oldRevision:0:7}"
                newShort="''${newRevision:0:7}"

                oldDate=""
                newDate=""
                if [[ "$(jq -r '.isGitHub' <<<"$entry")" == "true" ]]; then
                  owner="$(jq -r '.owner' <<<"$entry")"
                  repo="$(jq -r '.repo' <<<"$entry")"
                  oldDate="$(commit_date "$owner" "$repo" "$oldRevision")" || true
                  newDate="$(commit_date "$owner" "$repo" "$newRevision")" || true
                fi

                if [[ -n "$oldDate" && -n "$newDate" ]]; then
                  PINS_SUMMARY+="    $name: $oldShort ($oldDate) -> $newShort ($newDate)"$'\n'
                else
                  PINS_SUMMARY+="    $name: $oldShort -> $newShort"$'\n'
                fi
              done < <(jq -c '.[]' <<<"$CHANGED_PINS")

              if [[ -z "$PINS_SUMMARY" ]]; then
                PINS_SUMMARY="    (no pin changes)"$'\n'
              fi

              # With --keep-going, one root failure fans out into many "Cannot
              # build '...'. Reason: N dependencies failed." cascade lines,
              # which we drop. A build-time fixed-output hash mismatch prints
              # a tight "error: ...:" block with a couple of indented detail
              # lines (kept, as-is, for their alignment). An eval-time error
              # (e.g. a malformed hash string) instead opens with a bare
              # "error:" and a multi-paragraph, blank-line-separated "... while
              # evaluating ..." trace, ending in the actual "error: ..."
              # summary further indented; we want only that final line, not
              # the trace above it, so any "error: " match is taken on its
              # trimmed content (stripping the trace's own indentation) and
              # continuation lines are only kept while they don't themselves
              # look like a trace frame (a "... while" line, an "at ..."
              # source reference, or a "NNNN| ..." code excerpt).
              root_cause_errors() {
                awk '
                  {
                    t = $0
                    sub(/^[ \t]+/, "", t)
                  }
                  t ~ /^error: Cannot build / {
                    mode = "discard"
                    next
                  }
                  t ~ /^error: .+/ {
                    mode = "keep"
                    print t
                    next
                  }
                  mode == "keep" && /^[ \t]/ && t !~ /^…/ && t !~ /^at / && t !~ /\|/ {
                    print
                    next
                  }
                  {
                    mode = ""
                  }
                ' "$1"
              }

              build_system() {
                local system="$1"
                local output
                local log_file="$LOG_DIRECTORY/$system.log"

                echo "building $system from verified commit $TIP with updated pins..."
                if ! output="$(
                  nix-build \
                    --no-out-link \
                    --keep-going \
                    --option tarball-ttl 0 \
                    --expr '
                      { host, source }:
                      let
                        config = import (builtins.toPath source) { };
                      in
                      config.hosts.''${host}.config.system.build.toplevel
                    ' \
                    --argstr host "$system" \
                    --argstr source "$REPOSITORY" \
                    2>"$log_file"
                )"; then
                  cat "$log_file" >&2
                  echo "failed to build $system" >&2
                  return 1
                fi

                nix-store \
                  --add-root "$GC_ROOT_DIRECTORY/$system" \
                  --indirect \
                  --realise "$output" >/dev/null
                echo "pinned $system at $output"
              }

              FAILED_SYSTEMS=()
              SUCCESSFUL_SYSTEMS=()
              for system in ${toString systems}; do
                if build_system "$system"; then
                  SUCCESSFUL_SYSTEMS+=("$system")
                else
                  FAILED_SYSTEMS+=("$system")
                fi
              done

              {
                echo "Npins updated:"
                echo
                printf '%s' "$PINS_SUMMARY"

                if [[ ''${#SUCCESSFUL_SYSTEMS[@]} -gt 0 ]]; then
                  SUCCESSFUL_LIST="$(IFS=,; echo "''${SUCCESSFUL_SYSTEMS[*]}")"
                  echo
                  echo "Successfully built: ''${SUCCESSFUL_LIST//,/, }"
                fi

                for system in "''${FAILED_SYSTEMS[@]}"; do
                  echo
                  echo "''${system^} failed:"
                  echo
                  ERRORS="$(root_cause_errors "$LOG_DIRECTORY/$system.log")"
                  if [[ -z "$ERRORS" ]]; then
                    ERRORS="$(tail -n 20 "$LOG_DIRECTORY/$system.log")"
                  fi
                  printf '%s\n' "$ERRORS" | sed 's/^/    /'
                done
              } >"$SUMMARY_FILE"

              if [[ ''${#FAILED_SYSTEMS[@]} -gt 0 ]]; then
                echo "failed" >"$STATUS_FILE"
              else
                echo "ok" >"$STATUS_FILE"
              fi

              if git -C "$REPOSITORY" diff --quiet -- npins; then
                printf '%s\n' "$TIP" >"$LAST_ACCEPTED"
                echo "pins are already current; nothing to publish"
              else
                DIFF_HASH="$(git -C "$REPOSITORY" diff --binary HEAD -- npins | sha256sum | cut -d' ' -f1)"
                STATUS="ok"
                if [[ ''${#FAILED_SYSTEMS[@]} -gt 0 ]]; then
                  STATUS="failed"
                fi
                printf '%s %s %s\n' "$TIP" "$DIFF_HASH" "$STATUS" >"$PUBLISH_REQUEST"
                echo "queued pin update ($STATUS) for signed publication"
              fi

              if [[ ''${#FAILED_SYSTEMS[@]} -gt 0 ]]; then
                echo "builds failed for: ''${FAILED_SYSTEMS[*]}" >&2
                exit 1
              fi
            '';
          };

          "build-all-systems-publish" = {
            description = "Sign a pin update and merge it to master if every build succeeded";
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
                echo "no pin update is awaiting publication"
                exit 0
              fi

              read -r BASE EXPECTED_DIFF_HASH STATUS <"$PUBLISH_REQUEST"
              test "$(git_safe rev-parse HEAD)" = "$BASE"
              ${verifyCommit} "$REPOSITORY" "$BASE"

              ACTUAL_DIFF_HASH="$(git_safe diff --binary HEAD -- npins | sha256sum | cut -d' ' -f1)"
              if [[ "$ACTUAL_DIFF_HASH" != "$EXPECTED_DIFF_HASH" ]]; then
                echo "refusing to publish a pin diff changed after the build" >&2
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

              git_safe checkout -B npins-update "$BASE"
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

              if git_safe ls-remote --exit-code ${pushUrl} refs/heads/npins-update >/dev/null 2>&1; then
                git_safe fetch ${pushUrl} +refs/heads/npins-update:refs/remotes/origin/npins-update
                EXISTING_UPDATE="$(git_safe rev-parse refs/remotes/origin/npins-update)"
                if ! ${verifyCommit} "$REPOSITORY" "$EXISTING_UPDATE" --require-bot; then
                  echo "refusing to overwrite npins-update: existing head $EXISTING_UPDATE is not a bot commit" >&2
                  exit 1
                fi
              fi

              git_safe push --force ${pushUrl} HEAD:refs/heads/npins-update

              if [[ "$STATUS" == "ok" ]]; then
                git_safe push ${pushUrl} HEAD:refs/heads/master
                printf '%s\n' "$COMMIT" >"$LAST_ACCEPTED"
                echo "published signed pin update $COMMIT to master"
              else
                echo "left failing pin update $COMMIT on npins-update for manual investigation"
              fi

              rm -f "$PUBLISH_REQUEST"
            '';
          };

          "build-all-systems-notify" = {
            description = "Email a summary of the latest build-all-systems run";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            serviceConfig = commonHardening // {
              Type = "oneshot";
              User = "nix-cache-notifier";
              Group = "nix-cache-automation";
              SupplementaryGroups = [ "msmtp" ];
            };
            path = with pkgs; [
              coreutils
              msmtp
            ];
            script = ''
              set -euo pipefail
              shopt -s nullglob

              RECIPIENT="strik@olii.nl"
              SUMMARY_FILE=${statePath}/last-run-summary
              STATUS_FILE=${statePath}/last-run-status
              LOG_DIRECTORY=${statePath}/logs

              if [[ ! -s "$SUMMARY_FILE" ]]; then
                echo "no build-all-systems summary is available yet"
                exit 0
              fi

              STATUS_LABEL="OK"
              if [[ "$(cat "$STATUS_FILE" 2>/dev/null || echo ok)" != "ok" ]]; then
                STATUS_LABEL="FAILED"
              fi

              BOUNDARY="build-all-systems-$(date +%s)-$$"

              {
                printf 'Subject: [hestia] build-all-systems: %s\n' "$STATUS_LABEL"
                printf 'From: noreply@olii.nl\n'
                printf 'To: %s\n' "$RECIPIENT"
                printf 'MIME-Version: 1.0\n'
                printf 'Content-Type: multipart/mixed; boundary="%s"\n' "$BOUNDARY"
                printf '\n'

                printf -- '--%s\n' "$BOUNDARY"
                printf 'Content-Type: text/plain; charset=UTF-8\n\n'
                cat "$SUMMARY_FILE"
                printf '\n'

                for log_file in "$LOG_DIRECTORY"/*.log; do
                  printf -- '--%s\n' "$BOUNDARY"
                  printf 'Content-Type: text/plain; charset=UTF-8\n'
                  printf 'Content-Disposition: attachment; filename="%s"\n' "$(basename "$log_file")"
                  printf 'Content-Transfer-Encoding: base64\n\n'
                  base64 -w76 "$log_file"
                  printf '\n'
                done

                printf -- '--%s--\n' "$BOUNDARY"
              } | msmtp -a default "$RECIPIENT"
            '';
          };
        };
      };
    };
}
