let
  self = import ./self.nix { };
  hosts = import ./hosts.nix { inherit self; };
in
{
  inherit (self) lib modules;
  inherit hosts;
  packages = self.pkgs;
}
