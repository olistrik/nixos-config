default:
	nixos-rebuild switch

%:
	nix flake update --update-input $*
