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
	sudo chown root:wheel secrets/secrets.json
	sudo chmod 620 secrets/secrets.json

update:
	sudo nix flake update

new_key:
	scripts/new_key.sh
	scripts/update_keys.sh

update_keys:
	scripts/update_keys.sh
	
edit_sops:
	sops ./secrets/secrets.enc.yml

decrypt:
	sudo sops \
		--output secrets/secrets.json \
		--output-type json \
		-d secrets/secrets.enc.yml
	sudo nix flake lock --update-input secrets

sops: edit_sops decrypt
