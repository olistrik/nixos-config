{
  nixos.services.caddy-tailscale =
    { lib, config, ... }:
    with lib;
    let
      cfg = config.services.caddy;
    in
    {
      options.services.caddy.virtualHosts = mkOption {
        type = with types; attrsOf (submodule (
          { name, config, ... }:
          {
            options = {
              tailscale = {
                auth = mkEnableOption "Tailscale authentication via tailscale_auth";

                requireCapability = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                  example = "myapp.olii.nl/cap/auth";
                  description = ''
                    Tailscale application capability required for access.
                    Set to a capability name (e.g. `myapp.olii.nl/cap/auth`) to require
                    that the connecting user has that grant in Tailscale ACLs.
                    Requires `tailscale.auth = true`.
                  '';
                };

                permitLocal = mkOption {
                  type = types.bool;
                  default = false;
                  description = ''
                    Allow LAN clients to bypass Tailscale authentication.
                    Requests from `localNetworks` skip the auth and grant check entirely.
                  '';
                };

                localNetworks = mkOption {
                  type = with types; listOf str;
                  default = [ "192.168.0.0/16" "10.0.0.0/8" ];
                  description = ''
                    CIDR ranges considered local for `permitLocal`.
                  '';
                };
              };

              handler = mkOption {
                type = types.lines;
                default = "";
                example = ''reverse_proxy http://localhost:8080'';
                description = ''
                  Caddy directive lines for handling requests in this virtual host.
                  This is the canonical replacement for `extraConfig` for the main handler
                  content (reverse_proxy, respond, file_server, etc.).

                  When `tailscale.auth = true`, this content is wrapped inside the
                  Tailscale auth handler blocks (LAN bypass and authenticated grant path).
                  When `tailscale.auth = false` (or tailscale is not configured),
                  this is synonymous with `extraConfig` — it's appended verbatim.

                  You can still use `extraConfig` for additional directives appended
                  after `handler`.
                '';
              };
            };

            config.extraConfig = mkMerge [
              (mkIf config.tailscale.auth ''
                ${optionalString config.tailscale.permitLocal ''
                  @lan remote_ip ${concatStringsSep " " config.tailscale.localNetworks}
                  handle @lan {
                    ${config.handler}
                  }
                ''}

                handle {
                  tailscale_auth
                  ${optionalString (config.tailscale.requireCapability != null) ''
                    @has_grant expression `"${config.tailscale.requireCapability}" in {tailscale.grants}`
                    handle @has_grant {
                      ${config.handler}
                    }
                  ''}
                  handle {
                    respond "Access denied" 401
                  }
                }
              '')
              (mkIf (!config.tailscale.auth) config.handler)
            ];
          }
        ));
      };

      config = mkIf cfg.enable {
        systemd.services.caddy.serviceConfig.BindPaths = [
          "/run/tailscale/tailscaled.sock"
        ];
      };
    };
}
