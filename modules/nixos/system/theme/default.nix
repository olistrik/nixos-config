{ lib, ... }:
with lib; {
  options.olistrik.system.theme = {
    theme = mkOption {
      type = types.attrs;
      default = import ./ayu-mirage.nix;
    };
  };
}
