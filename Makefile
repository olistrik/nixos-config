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
	sudo find ../nixos/scripts -type f -exec chmod 755 {} +

update:
	sudo nix flake update

new_key:
	scripts/new_key.sh
	scripts/update_keys.sh

update_keys:
	scripts/update_keys.sh

secrets:
	nix run 'nixpkgs#sops' -- secrets/secrets.yml

decrypt:
	nix run 'nixpkgs#sops' -- \
		--output secrets/decrypted.json \
		--output-type json \
		-d secrets/secrets.yml


