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
