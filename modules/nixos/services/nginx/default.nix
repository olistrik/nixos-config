{ config, lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;

  cfgAuth = config.services.tailscaleAuth;
  cfgCommon = config.services.nginx.tailscaleAuth;

  virtualHostOptions = ({ config, ... }:
    let
      cfgHost = config.tailscaleAuth;
    in
    {
      options.tailscaleAuth = {
        enable = mkEnableOption "Tailscale forward authentication";
        requiresCapability = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };

      config = lib.mkIf cfgHost.enable {
        locations."/auth".extraConfig = builtins.concatStringsSep "\n" (
          [
            ''  
          internal;

          proxy_pass http://unix:${cfgAuth.socketPath};
          proxy_pass_request_body off;

          # Upstream uses $http_host here, but we are using gixy to check nginx configurations
          # gixy wants us to use $host: https://github.com/yandex/gixy/blob/master/docs/en/plugins/hostspoofing.md
          proxy_set_header Host $host;
          proxy_set_header Remote-Addr $remote_addr;
          proxy_set_header Remote-Port $remote_port;
          proxy_set_header Original-URI $request_uri;
          proxy_set_header X-Scheme                $scheme;
          proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
        ''
          ]
          ++ (lib.lists.optional (cfgHost.requiresCapability != null) ''
            proxy_set_header X-Requires-Capability "${cfgHost.requiresCapability}"
          '')
        );
        locations."/".extraConfig = ''
          auth_request /auth;
          auth_request_set $auth_user $upstream_http_tailscale_user;
          auth_request_set $auth_name $upstream_http_tailscale_name;
          auth_request_set $auth_login $upstream_http_tailscale_login;
          auth_request_set $auth_tailnet $upstream_http_tailscale_tailnet;
          auth_request_set $auth_profile_picture $upstream_http_tailscale_profile_picture;

          proxy_set_header X-Webauth-User "$auth_user";
          proxy_set_header X-Webauth-Name "$auth_name";
          proxy_set_header X-Webauth-Login "$auth_login";
          proxy_set_header X-Webauth-Tailnet "$auth_tailnet";
          proxy_set_header X-Webauth-Profile-Picture "$auth_profile_picture";
        '';
      };
    });
in
{
  options.services.nginx = with types; {
    virtualHosts = mkOption {
      type = attrsOf (submodule virtualHostOptions);
    };
  };

  config = {
    # submodule magic.
  };
}


















