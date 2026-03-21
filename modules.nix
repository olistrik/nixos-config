{
  self ? import ./self.nix { },
}:
self.lib.importModules ./modules
