#!/bin/sh

FLAKE_URI=github:olistrik/nixos-config
SYSTEMS="thoth hestia"

for system in $SYSTEMS; do
	echo "build ${system}" 
	nix build --dry-run ${FLAKE_URI}#nixosConfigurations.${system}.config.system.build.toplevel
done
