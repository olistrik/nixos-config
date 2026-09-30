{
  nixos.services.cypht =
    {
      config,
      lib,
      pkgs,
      my,
      ...
    }:
    let
      cfg = config.services.cypht;
      pool = config.services.phpfpm.pools.${cfg.pool};
      docRoot = "${cfg.dataDir}/www";

      envFile = pkgs.writeText "cypht.env" (
        lib.concatStrings (lib.mapAttrsToList (name: value: "${name}=${value}\n") cfg.settings)
      );

      # Symlink the (read-only) package contents into a writable docroot so a
      # real .env file can sit next to index.php: Cypht resolves both its own
      # `require`s and its .env file relative to the PHP process' cwd (there is
      # no absolute APP_PATH), so phpfpm's `chdir` has to point at a real
      # directory, not the Nix store.
      #
      # `modules/` is walked one level deeper (rather than symlinked whole) so
      # tsidpAuth's own module set can be added alongside upstream's without
      # needing a writable copy of the package's modules directory.
      packageRoot = "${cfg.package}/share/php/cypht";
      packageEntries = builtins.filter (n: n != "modules") (builtins.attrNames (builtins.readDir packageRoot));
      upstreamModules = builtins.attrNames (builtins.readDir "${packageRoot}/modules");

      customModules = lib.optionalAttrs cfg.tsidpAuth.enable {
        tsidp_auth = ./cypht-tsidp-auth;
      };

      defaultCyphtModules = [
        "core"
        "contacts"
        "local_contacts"
        "feeds"
        "imap"
        "smtp"
        "account"
        "idle_timer"
        "calendar"
        "themes"
        "nux"
        "developer"
        "history"
        "saved_searches"
        "advanced_search"
        "highlights"
        "profiles"
        "inline_message"
        "imap_folders"
        "keyboard_shortcuts"
        "tags"
        "brute_force"
      ]
      ++ lib.optional cfg.tsidpAuth.enable "tsidp_auth";
    in
    {
      options.services.cypht = {
        enable = lib.mkEnableOption "Cypht webmail";

        package = lib.mkPackageOption my.pkgs "cypht" { };
        phpPackage = lib.mkPackageOption pkgs "php" { };

        user = lib.mkOption {
          type = lib.types.str;
          default = "cypht";
          description = "User account under which Cypht (and its phpfpm pool) runs.";
        };

        group = lib.mkOption {
          type = lib.types.str;
          default = "cypht";
          description = "Group account under which Cypht (and its phpfpm pool) runs.";
        };

        pool = lib.mkOption {
          type = lib.types.str;
          default = "cypht";
          description = "Name of the phpfpm pool to use. A pool by this name is created if it doesn't already exist.";
        };

        dataDir = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/cypht";
          description = ''
            Directory holding the writable docroot symlink farm, per-user
            settings (`USER_SETTINGS_DIR`) and attachments (`ATTACHMENT_DIR`).
          '';
        };

        hostName = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = ''
            Caddy virtual host to configure for Cypht. Set to `null` to skip
            Caddy configuration entirely and wire up a reverse proxy yourself.
          '';
        };

        settings = lib.mkOption {
          type = with lib.types; attrsOf str;
          default = { };
          description = ''
            Cypht `.env` settings (see upstream's `.env.example`), rendered
            verbatim as `KEY=value` lines. Merged over single-user,
            no-database defaults (file-based user config, IMAP auth).
          '';
          example = {
            IMAP_AUTH_SERVER = "imap.example.com";
            DEFAULT_SMTP_SERVER = "smtp.example.com";
            ADMIN_USERS = "me@example.com";
          };
        };

        tsidpAuth = {
          enable = lib.mkEnableOption ''
            tsidp OIDC login, with a local-password fallback for LAN access.
            Replaces the stock IMAP-bind login and switches to unencrypted
            per-user settings storage, since neither login path yields a
            password suitable as a decryption key
          '';

          authSecretFile = lib.mkOption {
            type = lib.types.path;
            description = ''
              File holding a random secret used to HMAC-sign OAuth state and
              internal login handoff tokens. Generate with
              `openssl rand -base64 32`. Must be readable by
              `services.cypht.user`.
            '';
          };

          discoveryUrl = lib.mkOption {
            type = lib.types.str;
            default = "https://idp.olii.nl/.well-known/openid-configuration";
            description = "tsidp OIDC discovery document URL.";
          };

          clientId = lib.mkOption {
            type = lib.types.str;
            description = "OAuth client ID registered with tsidp (create it via tsidp's admin UI).";
          };

          clientSecretFile = lib.mkOption {
            type = lib.types.path;
            description = ''
              File holding the OAuth client secret for `clientId`. Must be
              readable by `services.cypht.user`.
            '';
          };

          userMap = lib.mkOption {
            type = with lib.types; attrsOf str;
            default = { };
            description = ''
              Maps a tsidp-verified `email` claim to a Cypht username.
              Identities not listed here are refused, regardless of what
              tsidp attests.
            '';
            example = {
              "oli@example.com" = "oli";
            };
          };

          localUsersFile = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = ''
              File holding a JSON object of `{"username": "bcrypt-hash"}`
              for LAN (non-Tailscale) password login. Generate a hash with
              `php -r 'echo password_hash("...", PASSWORD_DEFAULT);'`. Must
              be readable by `services.cypht.user`. Set to `null` to disable
              password login entirely (tsidp only).
            '';
          };
        };
      };

      config = lib.mkIf cfg.enable {
        services.cypht.settings = {
          USER_CONFIG_TYPE = lib.mkDefault "file";
          USER_SETTINGS_DIR = lib.mkDefault "${cfg.dataDir}/users";
          ATTACHMENT_DIR = lib.mkDefault "${cfg.dataDir}/attachments";
          AUTH_TYPE = lib.mkDefault "IMAP";
          SESSION_TYPE = lib.mkDefault "PHP";
          DEFAULT_LANGUAGE = lib.mkDefault "en";
          CYPHT_MODULES = lib.mkDefault (lib.concatStringsSep "," defaultCyphtModules);
        }
        // lib.optionalAttrs cfg.tsidpAuth.enable (
          {
            AUTH_TYPE = "custom";
            AUTH_CLASS = "Hm_Auth_Tsidp";
            USER_CONFIG_TYPE = "custom:Hm_User_Config_Plain";
            TSIDP_AUTH_SECRET_FILE = "${cfg.tsidpAuth.authSecretFile}";
            TSIDP_DISCOVERY_URL = cfg.tsidpAuth.discoveryUrl;
            TSIDP_CLIENT_ID = cfg.tsidpAuth.clientId;
            TSIDP_CLIENT_SECRET_FILE = "${cfg.tsidpAuth.clientSecretFile}";
            TSIDP_USER_MAP = builtins.toJSON cfg.tsidpAuth.userMap;
          }
          // lib.optionalAttrs (cfg.tsidpAuth.localUsersFile != null) {
            TSIDP_LOCAL_USERS_FILE = "${cfg.tsidpAuth.localUsersFile}";
          }
        );

        users.users.${cfg.user} = lib.mkIf (cfg.user == "cypht") {
          description = "Cypht service user";
          isSystemUser = true;
          inherit (cfg) group;
        };

        users.groups.${cfg.group} = lib.mkIf (cfg.group == "cypht") { };

        services.phpfpm.pools.${cfg.pool} = lib.mkIf (cfg.pool == "cypht") {
          inherit (cfg) user group phpPackage;
          settings = lib.mapAttrs (_: lib.mkDefault) {
            "listen.owner" = config.services.caddy.user;
            "listen.group" = config.services.caddy.group;
            "listen.mode" = "0600";
            "chdir" = docRoot;
            "pm" = "dynamic";
            "pm.max_children" = 32;
            "pm.start_servers" = 2;
            "pm.min_spare_servers" = 1;
            "pm.max_spare_servers" = 4;
            "pm.max_requests" = 500;
            "catch_workers_output" = 1;
          };
        };

        systemd.tmpfiles.rules = [
          "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -"
          "d ${docRoot} 0750 ${cfg.user} ${cfg.group} -"
          "d ${docRoot}/modules 0750 ${cfg.user} ${cfg.group} -"
          "d ${cfg.dataDir}/users 0750 ${cfg.user} ${cfg.group} -"
          "d ${cfg.dataDir}/attachments 0750 ${cfg.user} ${cfg.group} -"
        ]
        ++ (map (name: "L+ ${docRoot}/${name} - - - - ${packageRoot}/${name}") packageEntries)
        ++ (map (name: "L+ ${docRoot}/modules/${name} - - - - ${packageRoot}/modules/${name}") upstreamModules)
        ++ (lib.mapAttrsToList (name: src: "L+ ${docRoot}/modules/${name} - - - - ${src}") customModules)
        ++ [ "L+ ${docRoot}/.env - - - - ${envFile}" ];

        services.caddy.virtualHosts = lib.mkIf (cfg.hostName != null) {
          ${cfg.hostName}.handler = ''
            root * ${docRoot}
            encode gzip

            @hidden {
              path_regexp ^/\.
            }
            respond @hidden 403

            @sensitive {
              path_regexp \.(env|ini|log|conf|json|lock|ya?ml|md|txt|sh|bat|ps1|xml|bak|sql|dist|inc|cfg|db|csv)$
            }
            respond @sensitive 403

            php_fastcgi unix/${pool.socket}
            file_server
          '';
        };
      };
    };
}
