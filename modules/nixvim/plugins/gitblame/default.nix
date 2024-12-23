{ lib, config, ... }:
with lib;
with lib.olistrik;
with lib.olistrik.nixvim;
mkPlugin "gitblame" {
  inherit config;

  plugins.gitblame = {
    enable = true;
    settings = {
      delay = 1000;
    };
  };
}
