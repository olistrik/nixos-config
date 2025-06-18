{ config, ... }: {
  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@olii.nl";
    certs."olii.nl" = {
      dnsProvider = "cloudflare";
      domain = "*.olii.nl";
      credentialsFile = "/var/lib/acme/olii.nl.creds";
      group = config.services.nginx.group;
    };
  };

  olistrik.services.nixwarden.secrets = {
    "olii.nl.creds" = [{
      location = "/var/lib/acme/olii.nl.creds";
      wantedBy = [ "acme-olii.nl.service" ];
      userGroup = "acme:acme";
    }];
  };
}
