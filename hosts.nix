let
  sources = import ./npins;

  # import my custom library;
  lib = import ./lib.nix { };

  # recursively import all my modules.
  modules = lib.importModules ./modules;

  #
  pkgs = import ./packages.nix {
    inherit sources lib modules;
  };

  # init mmkHosts with `self` context
  mkHosts = lib.mkHostsWith {
    inherit
      sources
      lib
      modules
      pkgs
      ;
  };
in
mkHosts {
  thoth = { };
}
