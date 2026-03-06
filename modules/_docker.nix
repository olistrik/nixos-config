{ pkgs, ... }:
{
  _file = "docker.nix";
  virtualization.docker.package = pkgs.zsh;
}
