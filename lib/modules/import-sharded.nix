{ my, lib, ... }:
let
  inherit (my.lib.loader) listFiles;

  # depth: How many levels to traverse before wrapping as a module
  # path:  The current attribute breadcrumbs (for the 'key')
  # shards: The list of { file, value } pairs at this level
  loadDepth =
    depth: path: shards:
    if depth == 0 then
      # LEAF: We've reached the target depth.
      # Combine all shards into one "Virtual Module".
      {
        key = "sharded-module-" + (lib.concatStringsSep "." path);
        # Each shard's _file attribute ensures accurate error traces
        imports = map (s: {
          _file = s.file;
          imports = [ s.value ];
        }) shards;
      }
    else
      # BRANCH: Gather unique keys and recurse
      let
        allKeys = lib.unique (
          builtins.concatMap (s: if builtins.isAttrs s.value then builtins.attrNames s.value else [ ]) shards
        );
      in
      lib.genAttrs allKeys (
        key:
        let
          # Only pass shards that actually contain this key
          subShards = builtins.filter (s: builtins.isAttrs s.value && s.value ? ${key}) shards;
          nextShards = map (s: {
            file = s.file;
            value = s.value.${key};
          }) subShards;
        in
        loadDepth (depth - 1) (path ++ [ key ]) nextShards
      );

  importSharded =
    depth: dir:
    let
      paths = listFiles dir;
      initialShards = map (p: {
        file = toString p;
        value = import p;
      }) paths;
    in
    loadDepth depth [ ] initialShards;

in
{
  modules = {
    inherit importSharded;
  };
  # modules are currently depth 3: <class>.<namespace>.<module>
  importModules = importSharded 3;
}
