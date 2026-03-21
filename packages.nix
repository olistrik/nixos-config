args@{
  my ? import ./. args,
  ...
}:
let
  pkgs = import my.sources.nixpkgs { };
  mapAttrsRecursive =
    f: set:
    builtins.mapAttrs (
      name: val: if builtins.isAttrs val then mapAttrsRecursive f val else f [ ] val
    ) set;
  packages = mapAttrsRecursive (
    path: val: if builtins.isFunction val then (pkgs.callPackage val { }) else val
  ) (import ./packages);

  wrapped = import ./packages/wrapped { inherit my; };
in
packages // wrapped
