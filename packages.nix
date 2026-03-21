args@{
  my ? import ./my.nix args,
  ...
}:
let
  pkgs = import my.sources.nixpkgs { };
  pkgset = import ./packages;
  mapAttrsRecursive =
    f: set:
    builtins.mapAttrs (
      name: val: if builtins.isAttrs val then mapAttrsRecursive f val else f [ ] val
    ) set;
  packages = mapAttrsRecursive (
    path: val: if builtins.isFunction val then (pkgs.callPackage val { }) else val
  ) pkgset;
  wrappers = import ./wrappers.nix { inherit my; };
  nvf = import ./nvf.nix { inherit my; };
  wrapped = wrappers // nvf;
in
packages // { inherit wrapped; }
