{
  nixos.hosts.hestia = {
    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@olii.nl";
      certs = {
        "olii.nl" = {
          dnsProvider = "cloudflare";
          domain = "*.olii.nl";
          credentialsFile = "/var/lib/acme/olii.nl.creds";
        };
        "rhythmotion.nl" = {
          dnsProvider = "cloudflare";
          credentialsFile = "/var/lib/acme/olii.nl.creds";
          extraDomainNames = [ "signup.rhythmotion.nl" ];
        };
      };
    };

    olistrik.services.nixwarden.secrets = {
      "olii.nl.creds" = [
        {
          location = "/var/lib/acme/olii.nl.creds";
          wantedBy = [ "acme-olii.nl.service" ];
          userGroup = "acme:acme";
        }
      ];
    };
  };
}
