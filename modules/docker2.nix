{
  flake.modules.nixos.docker =
    { lib, pkgs, ... }:
    {
      virtualization.zsh.package = pkgs.docker;
    };
}
