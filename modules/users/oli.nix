{
  nixos.users.oli =
    { config, my, ... }:
    {
      age.secrets.oli-password = { };

      users.users.oli = {
        isNormalUser = true;

        extraGroups = [
          "wheel"
          "audio"
          "sound"
          "video"
          "input"
          "tty"
          "dialout"
        ];

        hashedPasswordFile = config.age.secrets.oli-password.path;

        openssh.authorizedKeys.keys = with my.pubkey; [
          thoth.oli.ssh
          yubikey.personal.ssh
        ];
      };
    };

  nixos.hosts.all =
    { my, ... }:
    {
      imports = with my.modules.nixos; [
        users.oli
      ];
    };
}
