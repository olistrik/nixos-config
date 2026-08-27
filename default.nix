args@{
  ...
}:
let
  my = {
    sources = (import ./npins) // args;
    lib = import ./lib.nix { inherit my; };
    pkgs = import ./packages.nix { inherit my; };
    projects = import ./projects.nix { inherit my; };
    modules = import ./modules.nix { inherit my; };
    hosts = import ./hosts.nix { inherit my; };
  };
in
my
