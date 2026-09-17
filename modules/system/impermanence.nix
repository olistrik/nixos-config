{
  nixos.system.impermanence =
    {
      my,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        (my.sources.impermanence + "/nixos.nix")
      ];

      fileSystems."/persist".neededForBoot = true;

      # logrotate replaces its state file with a rename(), which fails with
      # "Device or resource busy" if the state file itself is a bind mount
      # (as it would be if persisted directly via `files`). Point it at a
      # file inside a persisted directory instead, so the rename happens
      # inside the mount rather than on top of it.
      services.logrotate.extraArgs = [
        "--state"
        "/var/lib/logrotate/logrotate.status"
      ];

      environment.persistence."/persist" = {
        hideMounts = true;
        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/logrotate"
          "/var/lib/tailscale"
        ];
        files = [
          "/etc/machine-id"
        ];
      };

      # TODO: move somewhere better; or fix impermanence so
      # users can be mutable. /etc/shadow I think.
      users.mutableUsers = false;
    };
}
