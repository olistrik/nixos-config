{ lib, ... }:
{
  # Returns a list of all .nix files, excluding those starting with "_"
  loader.listFiles =
    dir:
    let
      expand =
        path:
        if builtins.readFileType path == "directory" then
          lib.filesystem.listFilesRecursive path
        else
          [ path ];
    in
    lib.filter (
      path:
      let
        name = builtins.baseNameOf path;
      in
      (lib.hasSuffix ".nix" name) && !(lib.hasPrefix "_" name)
    ) (lib.concatMap expand (if builtins.isList dir then dir else [ dir ]));
}
