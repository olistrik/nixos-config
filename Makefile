default:
	nixos-rebuild switch

perms:
	chown -R root:wheel ../nixos
	find ../nixos -type d -exec chmod 775 {} +
	find ../nixos -type f -exec chmod 664 {} +

%:
	nix flake update --update-input $*
