{ lib, config, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.collections.server;
in
{
  options.olistrik.collections.server = {
    enable = mkEnableOption "common server configuration";
  };

  config = mkIf cfg.enable {
    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      authorizedKeysFiles = lib.mkForce [
        "/etc/ssh/authorized_keys.d/%u"
      ];
    };

    olistrik.user.authorizedKeys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMcvHSxN1mFGgB6r19eHIqGKvhNOwddvVe43NwhKHmWzAAAABHNzaDo= oli@yubikey"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHwyuoI18ZEoo/c38XvI6HwvRlxigxd3lPzshi7RtVw2 oli@thoth"
    ];

    # Allow sudo for nixos-rebuild --use-remote-sudo, without passwordless sudo.
    # security.pam.sshAgentAuth.authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];   
    security.pam.sshAgentAuth.enable = true;
    security.pam.services.sudo.sshAgentAuth = true;
  };
}
