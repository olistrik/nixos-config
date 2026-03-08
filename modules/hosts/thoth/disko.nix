{
  nixos.hosts.thoth =
    { self, ... }:
    {
      imports = [
        (self.sources.disko + "/module.nix")
        ./_disk-config.nix
      ];
    };
}
