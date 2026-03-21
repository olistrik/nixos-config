{
  nixos.hosts.hestia =
    {
      my,
      pkgs,
      config,
      ...
    }:
    let
      tsidp = pkgs.callPackage (my.sources.tsidp + "/nix/package.nix") { };
      cfg = config.services.tsidp;
    in
    {
      disabledModules = [ "services/security/tsidp.nix" ];
      imports = [ (my.sources.tsidp + "/nix/module.nix") ];
      # overlays? modules?
      services.tsidp = {
        enable = true;
        package = tsidp;
        settings = {
          serverURL = "idp.olii.nl";
          unixSocket = "/run/tsidp.sock";
          useLocalTailscaled = true;
          disableTCP = true;
        };
      };

      services.caddy.virtualHosts = {
        ${cfg.settings.serverURL} = {
          extraConfig = ''
            reverse_proxy unix/${cfg.settings.unixSocket}
          '';
        };
      };

      users.groups.tsidp-sock = { };

      systemd = {
        sockets = {
          tsidp = {
            description = "TSIDP Socket";
            partOf = [ "tsidp.service" ];
            wantedBy = [ "sockets.target" ];
            listenStreams = [ cfg.settings.unixSocket ];
            socketConfig = {
              SocketMode = "0660";
              SocketGroup = "tsidp-sock";
            };
          };
        };

        services = {
          tsidp = {
            requires = [ "tsidp.socket" ];
            after = [ "tsidp.socket" ];
            serviceConfig = {
              SupplementaryGroups = [ "tsidp-sock" ];
            };
          };
          caddy = {
            wants = [ "tsidp.socket" ];
            after = [ "tsidp.socket" ];
            serviceConfig = {
              SupplementaryGroups = [ "tsidp-sock" ];
            };
          };
        };
      };
    };
}
