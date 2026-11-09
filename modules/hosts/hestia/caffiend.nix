{
  nixos.hosts.hestia =
    {
      my,
      config,
      ...
    }:
    {
      imports = [ my.projects.caffiend.nixosModules.default ];

      # Without this every reboot is a silent first run and misses anything that appeared while down.
      environment.persistence."/persist".directories = [
        "/var/lib/caffiend"
      ];

      age.secrets."caffiend-telegram-token" = {
        owner = "caffiend";
      };

      services.caffiend = {
        enable = true;
        telegram = {
          enable = true;
          tokenFile = config.age.secrets."caffiend-telegram-token".path;
          chatId = "9222743860";
        };
        shops.dak = {
          url = "https://www.dakcoffeeroasters.com";
          name = "DAK";
          categories = [
            "espresso"
          ];
          attributes = [
            "Origin"
            "Process"
            "Tasting notes"
          ];
          restocks = false;
        };
      };
    };
}
