{
  nixos.hosts.hestia =
    { my, ... }:
    {
      imports = [
        (my.sources.disko + "/module.nix")
        ./_disk-config.nix
      ];
    };
}
