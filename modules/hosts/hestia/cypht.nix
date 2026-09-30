{
  nixos.hosts.hestia =
    { my, ... }:
    {
      imports = with my.modules.nixos; [
        services.cypht
      ];

      environment.persistence."/persist".directories = [
        "/var/lib/cypht"
      ];

      services.cypht = {
        enable = true;
        hostName = "mail.olii.nl";

        settings = {
          IMAP_AUTH_NAME = "Migadu";
          IMAP_AUTH_SERVER = "imap.migadu.com";
          IMAP_AUTH_PORT = "993";
          IMAP_AUTH_TLS = "true";

          DEFAULT_SMTP_NAME = "Migadu";
          DEFAULT_SMTP_SERVER = "smtp.migadu.com";
          DEFAULT_SMTP_PORT = "465";
          DEFAULT_SMTP_TLS = "true";

          DEFAULT_EMAIL_DOMAIN = "olii.nl";

          # First IMAP login with this address becomes a Cypht admin
          # (Site Settings page). Adjust to whichever @olii.nl mailbox you'll
          # actually log in with first.
          ADMIN_USERS = "strik@olii.nl";
        };
      };
    };
}
