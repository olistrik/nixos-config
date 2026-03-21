{
  nixos.hosts.thoth =
    { my, ... }:
    {
      imports = [
        (my.sources.disko + "/module.nix")
        ./_disk-config.nix
      ];
    };
}
