{ config, lib, pkgs, ... }:
let
  package = pkgs.greetd.dlm;
in
{
  services.greetd = {
    enable = true;
    package = package;
    settings = {
      user = "${package}/bin/agreety --cmd sway";
    };
  };
}
