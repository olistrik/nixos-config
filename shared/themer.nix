{ config, lib, pkgs, ... }:
let
  cfg = config.system.themer;
in
with lib; {
  imports = [ ];
  options = {
    system.themer = {
      theme = mkOption {
        type = types.attrs;
        default = import ./themes/ayu-mirage.nix;
      };
    };
  };
  config = { };
}
