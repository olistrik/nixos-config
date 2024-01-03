{ lib, ... }:
let
  readFiles = path:
    lib.filterAttrs (key: value: value == "regular") (builtins.readDir path);
  readDirs = path:
    lib.filterAttrs (key: value: value == "directory") (builtins.readDir path);
  isModule = path: builtins.hasAttr "default.nix" (readFiles path);
  readModules = path:
    lib.filterAttrs (key: value: isModule (path + ("/" + key))) (readDirs path);
  children = path:
    lib.mapAttrsToList (key: value: path + ("/" + key)) (readModules path);
in { imports = children ./.; }
