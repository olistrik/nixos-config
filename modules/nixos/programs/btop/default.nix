# heavily influenced https://github.com/nix-community/home-manager/blob/a7117efb3725e6197dd95424136f79147aa35e5b/modules/programs/alacritty.nix
{ config, lib, pkgs, ... }:
with lib; with lib.olistrik;
let
  inherit (lib.attrsets) filterAttrs;

  cfg = config.olistrik.programs.btop;
in
{
  options.olistrik.programs.btop = with types; {
    enable = mkEnableOption "btop";
    package = mkOpt package pkgs.btop "Which btop package to use.";
    cudaSupport = mkOpt (nullOr bool) null "Enable Nvidia GPU Support.";
    rocmSupport = mkOpt (nullOr bool) null "Enable AMD GPU Support.";
  };

  config = mkIf cfg.enable
    {
      environment.systemPackages = [
        (cfg.package.override (filterAttrs (_: v: v != null) {
          inherit (cfg) cudaSupport rocmSupport;
        }))
      ];
    };
}
