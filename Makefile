default:
	sudo nixos-rebuild switch

%:
	sudo nix flake update --update-input $*
