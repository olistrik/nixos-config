{
  # TODO: Probably wrap this?
  nixos.programs.direnv =
    { my, pkgs, ... }:
    let
      unstable = import my.sources.unstable {
        system = pkgs.stdenv.hostPlatform.system;
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
