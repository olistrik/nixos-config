#!/usr/bin/env bash

echo hosts:
i=-1
for D in hosts/*/; do
	name=$(basename $D)
	((i=i+1))
	echo "  ($i) ${name}"
done

while true; do
	printf ": " $i
	read
	if [[ "${REPLY}" =~ ^[0-9]+$ ]] && [[ ${REPLY} -le $i ]] && [[ ${REPLY} -ge 0 ]]; then  
		break;
	fi
	echo "please enter a number between 0 and $i"
done

rm configuration.nix
echo linking configuration...
for D in hosts/*/; do
	if [[ $REPLY -eq 0 ]]; then
		ln -s /etc/nixos/${D}configuration.nix configuration.nix
		break;
	fi
	(($REPLY=$REPLY-1))
done
echo done!
