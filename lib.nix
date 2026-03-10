{
  sources ? import ./npins,
  pkgs ? import sources.nixpkgs { },
}:
let
  lib = pkgs.lib;
  inherit ((import ./lib/loader/list-files.nix { inherit lib; }).loader) listFiles;

  # 1. Get the list of files (excluding underscore-prefixed)
  libFiles = listFiles ./lib;

  # 2. Define the library loader
  # We use lib.fix here so that 'self' is available inside every function
  finalLib = lib.fix (
    final:
    let
      # Context to be passed to every library file
      ctx = {
        inherit lib pkgs;
        self = {
          inherit sources;
          # if lib needs anything else; it will go in here.
          lib = final;
        };
      };

      # Import and apply context to every file
      # This results in a list of nested attrsets: [{ foo.bar = ...; }]
      appliedFiles = map (f: import f ctx) libFiles;

      # Deep merge the results into one tree
      # lib.recursiveUpdate works perfectly for standard attrsets
    in
    builtins.foldl' lib.recursiveUpdate { } appliedFiles
  );
in
finalLib
