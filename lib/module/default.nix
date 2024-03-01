# Copied and modified from https://github.com/jakehamilton/config/blob/af7157f331d1c5f7daf74fa84a2b20e55b08ab0b/lib/module/default.nix
{ lib, ... }:
with lib; rec {

  ## Create a NixOS module option.
  ##
  ## ```nix
  ## lib.mkOpt nixpkgs.lib.types.str "My default" "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt = type: default: description: mkOption {
    inherit type default description;
  };

  mkBool = default: description: mkOpt types.bool default description;

  ## Quickly enable an option.
  ##
  ## ```nix
  ## services.nginx = enabled;
  ## ```
  ##
  #@ true
  enabled = {
    enable = true;
  };

  ## Quickly disable an option.
  ##
  ## ```nix
  ## services.nginx = enabled;
  ## ```
  ##
  #@ false
  disabled = {
    enable = false;
  };

  basicOptions = module: {
    enable = mkOpt types.bool false "Whether to enable ${module}.";
  };
}
