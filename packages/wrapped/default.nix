{ my }:
let
  wrappers = import ./wrappers.nix { inherit my; };
  nvf = import ./nvf.nix { inherit my; };
in
{
  wrapped = wrappers // nvf;
}
