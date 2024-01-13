{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.nixwarden;
in
{
  options.services.nixwarden = {
    package = mkOption {
      type = types.package;
      default = pkgs.bws;
    };
    accessTokenFile = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    project = mkOption {
      type = types.str;
      default = "nixwarden";
    };
    secrets = mkOption {
      type = with types;
        attrsOf (submodule {
          options = {
            location = mkOption {
              type = nullOr str;
              default = null;
              description = "";
            };
            wantedBy = mkOption {
              type = listOf str;
              default = [ ];
              description = "";
            };
            userGroup = mkOption {
              type = str;
              default = "root:root";
              description = "";
            };
            permissions = mkOption {
              type = str;
              default = "400";
              description = "";
            };
          };
        });
      default = { };
      description = "";
    };
  };

  config =
    let
      bws = "${cfg.package}/bin/bws";
      jq = "${pkgs.jq}/bin/jq";

      wantedBy =
        lib.unique (concatMap (secret: secret.wantedBy) (attrValues cfg.secrets));

      writeSecret = name: secret: "writeSecret ${name} ${secret.location} ${secret.userGroup} ${secret.permissions}";

      writeSecrets = concatStringsSep "\n" (mapAttrsToList writeSecret cfg.secrets);
      secretKeys = mapAttrsToList (name: value: name) cfg.secrets;
    in
    mkIf (length secretKeys > 0) {
      assertions = [
        {
          assertion = cfg.accessTokenFile != null;
          message = "an access token file is required for nixwarden.";
        }
      ];
      systemd.services = {
        nixwarden = {
          description = "Nixwarden";
          before = wantedBy;
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ] ++ wantedBy;
          serviceConfig = {
            Type = "oneshot";
            ExecStart = pkgs.writeScript "nixwarden-sync" ''
              #!/bin/sh
              token=$(cat ${cfg.accessTokenFile})  
              secrets=$(${bws} --access-token $token secret list)

              function getSecret() {
                  echo $secrets | ${jq} ".[] | select(.key == \"$1\").value"
              }

              function writeSecret() {
                getSecret $1 | xargs printf > $2
                chown $3 $2
                chmod $4 $2
              }

              ${writeSecrets}
            '';
          };
        };
      };

      environment.systemPackages = with pkgs; [
        (
          writeScriptBin "nixwarden" ''
            token=$(cat ${cfg.accessTokenFile})  
            secrets=$(${bws} --access-token $token secret list)

            function getSecret() {
              echo $secrets | ${jq} ".[] | select(.key == \"$1\").value" | xargs printf
            }

            function writeSecret() {
              echo "$2 ($3 $4):"
              getSecret $1
            }

            ${writeSecrets}
          ''
        )
      ];
    };
}
