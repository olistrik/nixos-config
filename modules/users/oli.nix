{
  nixos.users.oli = {
    nix.settings.trusted-users = [ "oli" ];

    users.users.oli = {
      isNormalUser = true;

      extraGroups = [
        "wheel"
        "audio"
        "sound"
        "video"
        "input"
        "tty"
      ];

      # TODO: We can do better.
      hashedPasswordFile = "/persist/secret/user.password";

      openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMcvHSxN1mFGgB6r19eHIqGKvhNOwddvVe43NwhKHmWzAAAABHNzaDo= oli@yubikey"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHwyuoI18ZEoo/c38XvI6HwvRlxigxd3lPzshi7RtVw2 oli@thoth"
      ];
    };
  };

  nixos.hosts.all =
    { self, ... }:
    {
      imports = with self.modules.nixos; [
        users.oli
      ];
    };
}
