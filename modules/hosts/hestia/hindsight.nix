{
  nixos.hosts.hestia =
    {
      config,
      lib,
      pkgs,
      my,
      ...
    }:
    with lib;
    let
      cfg = config.services.hindsight;
    in
    {
      options.services.hindsight = {
        enable = mkEnableOption "Hindsight API memory engine";

        package = mkOption {
          type = types.package;
          default = my.pkgs.hindsight-api;
          defaultText = literalExpression "my.pkgs.hindsight-api";
          description = "hindsight-api-slim package to use";
        };

        host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Bind address for the API server";
        };

        port = mkOption {
          type = types.port;
          default = 8888;
          description = "Port for the API server";
        };

        llmProvider = mkOption {
          type = types.str;
          default = "deepseek";
          description = "LLM provider (passed as HINDSIGHT_API_LLM_PROVIDER)";
        };

        llmApiKeyFile = mkOption {
          type = types.nullOr types.str;
          default = "/var/lib/hindsight/.env";
          description = "Path to environment file containing HINDSIGHT_API_LLM_API_KEY (managed by nixwarden)";
        };

        environment = mkOption {
          type = types.attrsOf types.str;
          default = { };
          description = "Extra environment variables for the hindsight-api service";
        };

        virtualHost = mkOption {
          type = types.str;
          default = "hindsight.olii.nl";
          description = "Caddy virtual host name";
        };
      };

      config = mkIf cfg.enable {
        # Fixed user so nixwarden (which runs before this service) can write
        # the env file with the correct ownership.
        users.users.hindsight = {
          isSystemUser = true;
          group = "hindsight";
        };
        users.groups.hindsight = { };

        # PostgreSQL database and user (peer auth via Unix socket)
        services.postgresql = {
          enable = true;
          extensions = plug: with plug; [ pgvector ];
          ensureDatabases = [ "hindsight" ];
          ensureUsers = [
            {
              name = "hindsight";
              ensureDBOwnership = true;
            }
          ];
        };

        # One-shot to create the pgvector extension as superuser before the
        # API server runs its migrations.  Hindsight's own user isn't superuser
        # and can't CREATE EXTENSION.
        systemd.services.hindsight-pg-init = {
          description = "Initialize Hindsight PostgreSQL extensions";
          before = [ "hindsight-api.service" ];
          wantedBy = [ "hindsight-api.service" ];
          serviceConfig = {
            Type = "oneshot";
            User = "postgres";
          };
          script = ''
            				${pkgs.postgresql}/bin/psql -d hindsight -c "CREATE EXTENSION IF NOT EXISTS vector;"
            			'';
        };

        # Systemd service
        systemd.services.hindsight-api = {
          description = "Hindsight API — agent memory engine";
          after = [
            "network.target"
            "postgresql.service"
            "hindsight-pg-init.service"
          ];
          wants = [
            "postgresql.service"
            "hindsight-pg-init.service"
          ];
          wantedBy = [ "multi-user.target" ];

          script = "${cfg.package}/bin/hindsight-api";

          serviceConfig = {
            Type = "simple";
            User = "hindsight";
            Group = "hindsight";
            StateDirectory = "hindsight";
            WorkingDirectory = "/var/lib/hindsight";

            Environment = [
              "HINDSIGHT_API_HOST=${cfg.host}"
              "HINDSIGHT_API_PORT=${toString cfg.port}"
              # Unix socket peer auth.  Socket path omitted because
              # to_libpq_url() URL-encodes query values, mangling paths.
              "HINDSIGHT_API_DATABASE_URL=postgresql:///hindsight"
              "HINDSIGHT_API_LLM_PROVIDER=${cfg.llmProvider}"
              # Remote embeddings via OpenAI-compatible endpoint (same base URL as LLM provider)
              "HINDSIGHT_API_EMBEDDINGS_PROVIDER=openai"
              # Disable local reranker — set to "cohere" and add HINDSIGHT_API_RERANKER_COHERE_API_KEY
              # in the env file to enable reranking.
              "HINDSIGHT_API_RERANKER_PROVIDER=rrf"
              "HINDSIGHT_API_RUN_MIGRATIONS_ON_STARTUP=true"
            ];

            # Leading dash means "ignore if file doesn't exist" — nixwarden may
            # not have synced yet on first boot.
            EnvironmentFile = optional (cfg.llmApiKeyFile != null) "-${cfg.llmApiKeyFile}";

            # Hardening
            PrivateTmp = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            NoNewPrivileges = true;
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
              "AF_UNIX"
            ];
            RestrictNamespaces = true;
            CapabilityBoundingSet = "";
          };
        };

        # Caddy reverse proxy
        services.caddy.virtualHosts.${cfg.virtualHost} = {
          useACMEHost = "olii.nl";
          handler = ''
            reverse_proxy http://${cfg.host}:${toString cfg.port}
          '';
        };

        # Nixwarden secret for LLM API key
        olistrik.services.nixwarden.secrets = mkIf (cfg.llmApiKeyFile != null) {
          "hindsight-api.env" = [
            {
              location = cfg.llmApiKeyFile;
              wantedBy = [ "hindsight-api.service" ];
              userGroup = "hindsight:hindsight";
            }
          ];
        };
      };
    };
}
