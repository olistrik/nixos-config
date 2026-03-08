let
  sources = import ./npins;

  # import my custom library;
  lib = import ./lib.nix { inherit sources; };

  # recursively import all my modules.
  modules = lib.importModules ./modules;

  # init mmkHosts with `self` context
  mkHosts = lib.mkHostsWith {
    inherit sources lib modules;
  };
in
mkHosts {
  thoth = { };
}
