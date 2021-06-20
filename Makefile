test:
	git add -A
	sudo nixos-rebuild test
	sudo rm -rf result

switch: perms
	git add -A
	sudo nixos-rebuild switch
	git commit

perms:
	sudo chown -R root:wheel ../nixos
	sudo find ../nixos -type d -exec chmod 775 {} +
	sudo find ../nixos -type f -exec chmod 664 {} +
	sudo find ../nixos/scripts -type f -exec chmod 755 {} +
	sudo chown root:wheel secrets/secrets.json
	sudo chmod 600 secrets/secrets.json

update:
	sudo nix flake update

_new_key:
	scripts/new_key.sh

_update_keys:
	scripts/update_keys.sh
	
_edit_sops:
	sops ./secrets/secrets.enc.yml

_decrypt:
	sudo sops \
		--output secrets/secrets.json \
		--output-type json \
		-d secrets/secrets.enc.yml
	sudo scripts/update_inputs.sh secrets

new_key: _new_key _update_keys

sops: _edit_sops _decrypt
