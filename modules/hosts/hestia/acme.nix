{
  nixos.hosts.hestia = { config, ... }: {
    age.secrets."acme-cloudflare.env" = {
      owner = "acme";
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@olii.nl";
      certs = {
        "olii.nl" = {
          dnsProvider = "cloudflare";
          domain = "*.olii.nl";
          environmentFile = config.age.secrets."acme-cloudflare.env".path;
        };
        # "rhythmotion.nl" = {
        #   dnsProvider = "cloudflare";
        #   environmentFile = "/var/lib/acme/olii.nl.creds";
        #   extraDomainNames = [ "signup.rhythmotion.nl" ];
        # };
      };
    };
  };
}
