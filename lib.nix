args@{
  my ? import ./my.nix args,
  ...
}:
let
  pkgs = import my.sources.nixpkgs { };
  lib = pkgs.lib;

  inherit ((import ./lib/loader/list-files.nix { inherit lib; }).loader) listFiles;

  libFiles = listFiles ./lib;

  ctx = { inherit lib pkgs my; };
  appliedFiles = map (f: import f ctx) libFiles;

in
builtins.foldl' lib.recursiveUpdate { } appliedFiles
