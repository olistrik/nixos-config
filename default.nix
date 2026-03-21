let
  my = import ./my.nix { };
  hosts = import ./hosts.nix { inherit my; };
in
{
  inherit (my) lib modules;
  inherit hosts;
  packages = my.pkgs;
}
