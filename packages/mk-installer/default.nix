{pkgs, ...}:
pkgs.writeShellApplication {
  name = "mk-installer"; 
  runtimeInputs = with pkgs; [ gum nix ]; 
  text = '' 
    #!${pkgs.bash}/bin/bash

    echo "Pick ssh key for root user:"
    SSH_AUTH_KEY=$(find "$HOME"/.ssh -type f -name "*.pub" -print0 | xargs -0 gum choose)
    echo "$SSH_AUTH_KEY"

    export SSH_AUTH_KEY
    nix build "github:olistrik/nixos-config/snowfall#install-isoConfigurations.minimal"

    # fdisk -l | grep -Eo /dev/sd.: [0-9.]+ [a-zA-Z]+
  '';
}
