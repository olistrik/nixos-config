{
  # TODO: Probably wrap this?
  nixos.programs.direnv =
    { my, pkgs, ... }:
    let
      unstable = import my.sources.unstable {
        inherit (pkgs) system;
        config.allowUnfree = true;
      };
    in
    {
      programs.direnv = {
        enable = true;
        nix-direnv.package = unstable.nix-direnv;
      };
    };
}
