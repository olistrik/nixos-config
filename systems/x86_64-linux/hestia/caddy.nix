{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.olistrik.services.caddy;
in
{
  options = with types; {
    services.caddy.virtualHosts = mkOption {
      type = attrsOf (submodule ({ name, config, ... }: {
        config = mkIf (hasSuffix "olii.nl" name) {
          useACMEHost = "olii.nl";
        };
      }));
    };
  };

  config = {
    services.caddy = {
      enable = true;
      logFormat = mkForce ''
        level DEBUG
      '';
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/tailscale/caddy-tailscale@v0.0.0=github.com/olistrik/caddy-tailscale@fix-tailscale-auth-panic"
        ];
        hash = "sha256-IoN2gM0kp6b+2mNp7wCkw0ZC76V7/lFkFvJIOaeBljg=";
        doInstallCheck = false;
      };
      virtualHosts = {
        "hello.olii.nl".extraConfig = ''
          tailscale_auth
          respond `Hello {{http.auth.user.tailscale_login}}`
        '';
      };
    };

    systemd.services.caddy = {
      serviceConfig = {
        BindPaths = [ "/run/tailscale/tailscaled.sock" ];
      };
    };
  };
}

# services.oauth2-proxy = {
#   enable = true;
#   provider = "oidc";
#   keyFile = "/persist/secret/oauth2-proxy.keys";
#   redirectURL = "https://auth.olii.nl/oauth2/callback";
#   oidcIssuerUrl = "https://idp.olii.nl";
#   approvalPrompt = "auto";
#   cookie = {
#     secure = true;
#     domain = ".olii.nl";
#   };
#   email.domains = [ "*" ];
#   reverseProxy = true;
#   extraConfig = {
#     whitelist-domain = [ ".olii.nl" ];
#   };
# };


# extraConfig = ''
#   (oauth2-proxy) {
#     handle /oauth2/* {
#       reverse_proxy ${oauth2-proxy.httpAddress} {
#         header_up X-Real-IP {remote_host}
#         header_up X-Forwarded_Uri {uri}
#       }
#     }
#
#     handle {
#       forward_auth ${oauth2-proxy.httpAddress} {
#         uri /oauth2/auth
#         header_up X-Real-IP {remote_host}
#
#         @error status 401
#         handle_response @error {
#           redir * /oauth2/sign_in?rd={scheme}://{host}{uri}
#         }
#       }
#
#       {block}
#     }
#   }
# '';

# package = pkgs.caddy.withPlugins {
#   plugins = [ "github.com/greenpau/caddy-security@v1.1.31" ];
#   hash = "sha256-6WJ403U6XbaNfncIvEJEwUc489yyRhv4jP7H/RVJWlM=";
# };
# globalConfig = ''
#   order authenticate before respond
#   order authorize before basicauth
#
#   security {
#     oauth identity provider generic {
#       realm generic
#       driver generic
#
#       client_id {env.OIDC_CLIENT_ID}
#       client_secret {env.OIDC_CLIENT_SECRET}
#       scopes openid email profile
#       base_auth_url https://idp.olii.nl/
#       metadata_url https://idp.olii.nl/.well-known/openid-configuration
#     }sha256-6WJ403U6XbaNfncIvEJEwUc489yyRhv4jP7H/RVJWlM=
#     authentication portal myportal {
#       crypto default token lifetime 3600
#       crypto key sign-verify {env.JWT_SHARED_KEY}
#       enable identity provider generic
#       cookie domain olii.nl
#       ui {
#         links {
#           "My Identity" "/whoami" icon "las la-user"
#         }
#       }
#     }
#
#     authorization policy mypolicy {
#       set auth url https://auth.olii.nl/oauth2/generic
#       crypto key verify {env.JWT_SHARED_KEY}
#       allow roles authp/admin authp/user
#       validate bearer header
#       inject headers with claims
#     }
#   }
# '';
# virtualHosts = {
#   "auth.olii.nl".extraConfig = ''
#     authenticate with myportal
#   '';
# };
