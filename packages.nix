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

  nix-fast-build = pkgs.callPackage "${my.sources.nix-fast-build}/default.nix" { };
in
packages // wrapped // {
  inherit nix-fast-build;
}
