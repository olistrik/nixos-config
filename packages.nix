{
  self ? import ./self.nix { },
  sources ? self.sources,
  pkgs ? import sources.nixpkgs { },
  ...
}@args:
let
  pkgset = import ./packages;
  mapAttrsRecursive =
    f: set:
    builtins.mapAttrs (
      name: val: if builtins.isAttrs val then mapAttrsRecursive f val else f [ ] val
    ) set;
  packages = mapAttrsRecursive (
    path: val: if builtins.isFunction val then (pkgs.callPackage val { }) else val
  ) pkgset;
  wrappers = import ./wrappers.nix args;
  nvf = import ./nvf.nix args;
  wrapped = wrappers // nvf;
in
packages // { inherit wrapped; }
