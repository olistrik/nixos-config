{
  nixos.hosts.hestia =
    { config, ... }:
    {
      users.users.msmtp = {
        home = "/var/lib/msmtp/";
        group = "msmtp";
        isSystemUser = true;
      };
      users.groups.msmtp.members = [
        "nextcloud"
        "oli"
      ];

      age.secrets."msmtp-noreply.pass" = {
        owner = "msmtp";
        group = "msmtp";
        mode = "0440";
      };

      programs.msmtp = {
        enable = true;
        accounts.default = {
          host = "smtp.migadu.com";
          port = 465;
          auth = "plain";
          tls = "on";
          tls_starttls = "off";
          from = "noreply@olii.nl";
          user = "noreply@olii.nl";
          passwordeval = "cat ${config.age.secrets."msmtp-noreply.pass".path}";
        };
        extraConfig = ''
          syslog LOG_MAIL
        '';
      };
    };
}
