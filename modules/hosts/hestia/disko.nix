{
  nixos.hosts.hestia =
    { self, ... }:
    {
      imports = [
        (self.sources.disko + "/module.nix")
        ./_disk-config.nix
      ];
    };
}
