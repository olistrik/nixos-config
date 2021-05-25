test:
	git add -A
	sudo nixos-rebuild test
	sudo rm -rf result

switch: perms
	git add -A
	git commit
	sudo nixos-rebuild switch

perms:
	sudo chown -R root:wheel ../nixos
	sudo find ../nixos -type d -exec chmod 775 {} +
	sudo find ../nixos -type f -exec chmod 664 {} +

update:
	sudo nix flake update
