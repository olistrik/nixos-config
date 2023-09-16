test:
	git add -A
	sudo nixos-rebuild test --flake ".#"
	sudo rm -rf result

switch: perms
	git add -A
	[[ -z $$(git status -s) ]] || git commit
	sudo nixos-rebuild switch --flake ".#"
	[[ -z $$(git status -s) ]] || git commit -am "chore: update flake.lock"
	git push

perms:
	sudo chown -R root:wheel ../nixos
	sudo find ../nixos -type d -exec chmod 775 {} +
	sudo find ../nixos -type f -exec chmod 664 {} +
	sudo find ../nixos/scripts -type f -exec chmod 755 {} +

update:
	sudo nix flake update

iso:
	sudo nix build .#liveUsb
