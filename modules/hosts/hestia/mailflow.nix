{
  nixos.hosts.hestia =
    {
      config,
      lib,
      pkgs,
      my,
      ...
    }:
    let
      cfg = config.services.mailflow;
      host = "mail.olii.nl";
    in
    {
      options.services.mailflow.port = lib.mkOption {
        type = lib.types.port;
        default = 3100;
        description = "Port for the MailFlow backend (loopback only)";
      };

      config = {
        age.secrets."mailflow.env" = { };

        users.users.mailflow = {
          isSystemUser = true;
          group = "mailflow";
        };
        users.groups.mailflow = { };

        # Peer auth over the unix socket; the DB_PASSWORD MailFlow insists on
        # is a dummy in the env file and never checked.
        services.postgresql = {
          ensureDatabases = [ "mailflow" ];
          ensureUsers = [
            {
              name = "mailflow";
              ensureDBOwnership = true;
            }
          ];
        };

        services.redis.servers.mailflow = {
          enable = true;
          port = 0;
          user = "mailflow";
        };

        environment.persistence."/persist".directories = [
          "/var/lib/redis-mailflow"
        ];

        systemd.services.mailflow = {
          description = "MailFlow webmail backend";
          after = [
            "network.target"
            "postgresql.service"
            "redis-mailflow.service"
          ];
          wants = [
            "postgresql.service"
            "redis-mailflow.service"
          ];
          wantedBy = [ "multi-user.target" ];

          environment = {
            NODE_ENV = "production";
            PORT = toString cfg.port;
            APP_URL = "https://${host}";
            FRONTEND_URL = "https://${host}";
            DB_HOST = "/run/postgresql";
            DB_NAME = "mailflow";
            DB_USER = "mailflow";
            REDIS_URL = "unix://${config.services.redis.servers.mailflow.unixSocket}";
            # Only Caddy sits in front of us.
            TRUST_PROXY_HOPS = "1";
            UPDATE_CHECK_DISABLED = "true";
          };

          serviceConfig = {
            ExecStart = lib.getExe' my.pkgs.mailflow.backend "mailflow-backend";
            # Provides SESSION_SECRET, ENCRYPTION_KEY (64 hex chars) and DB_PASSWORD (dummy).
            EnvironmentFile = config.age.secrets."mailflow.env".path;
            User = "mailflow";
            Group = "mailflow";
            Restart = "on-failure";

            # Hardening
            PrivateTmp = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            NoNewPrivileges = true;
            RestrictNamespaces = true;
            CapabilityBoundingSet = "";
          };
        };

        services.caddy.virtualHosts.${host}.handler = ''
          @backend path /api/* /oauth/* /auth/oidc/* /ws
          handle @backend {
            reverse_proxy http://127.0.0.1:${toString cfg.port}
          }

          handle {
            root * ${my.pkgs.mailflow.frontend}
            header Cache-Control "no-store"
            try_files {path} /index.html
            file_server
          }
        '';
      };
    };
}
