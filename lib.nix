{
  sources ? import ./npins,
  pkgs ? import sources.nixpkgs { },
}:
let
  lib = pkgs.lib;
  inherit ((import ./lib/loader/list-files.nix { inherit lib; }).loader) listFiles;

  libFiles = listFiles ./lib;

  finalLib = lib.fix (
    final:
    let
      ctx = {
        inherit lib pkgs;
        self = {
          inherit sources;
          lib = final;
        };
      };
      appliedFiles = map (f: import f ctx) libFiles;

    in
    builtins.foldl' lib.recursiveUpdate { } appliedFiles
  );
in
finalLib
