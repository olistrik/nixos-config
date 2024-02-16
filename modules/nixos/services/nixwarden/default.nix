{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.olistrik.services.nixwarden;
in
{
  options.olistrik.services.nixwarden = {
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
        attrsOf (listOf (submodule {
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
        }));
      default = { };
      description = "";
    };
  };

  config =
    let
      bws = "${cfg.package}/bin/bws";
      jq = "${pkgs.jq}/bin/jq";
      host = "${pkgs.dig.host}/bin/host";

      # {foo: [{wantedBy}], bar: [{wantedBy}, {wantedBy}]}
      # attrValues: [[{wantedBy}], [{wantedBy}, {wantedBy}]]
      # concatLists: [{wantedBy}{wantedBy}{wantedBy}]
      # 

      writeSecret = name: file: "writeSecret ${name} ${file.location} ${file.userGroup} ${file.permissions}";


      keys = attrNames cfg.secrets;
      files = concatLists (attrValues cfg.secrets);
      wantedBy = lib.unique (concatMap (file: file.wantedBy) files);
      writeSecrets = concatStringsSep "\n"
        (concatLists
          (mapAttrsToList (name: files: (map (file: (writeSecret name file)) files)) cfg.secrets));
    in
    mkIf (length keys > 0) {
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
              until ${host} example.com > /dev/null; do sleep 1; done
            
              echo fetching secrets...
              secrets=$(${bws} --access-token $token secret list)

              function getSecret() {
                  echo $secrets | ${jq} ".[] | select(.key == \"$1\").value"
              }

              echo writing secrets...
              function writeSecret() {
                echo "writing secret \"$1\" to \"$2\""
                getSecret $1 | xargs printf > $2

                echo "setting ownership to \"$3\" with permissions \"$4\"" 
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
