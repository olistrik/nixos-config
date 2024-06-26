{ lib, config, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.collections.server;
in
{
  options.olistrik.collections.server = basicOptions "server configuration";

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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIL0q7NgpGYIG6vQqzJTD64jUASuDWxw7DNKsrw+j3G/ oli@nixogen"
    ];

    # Allow sudo for nixos-rebuild --use-remote-sudo, without passwordless sudo.
    # security.pam.sshAgentAuth.authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];   
    security.pam.sshAgentAuth.enable = true;
    security.pam.services.sudo.sshAgentAuth = true;
  };
}
