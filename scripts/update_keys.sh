#!/usr/bin/env bash

echo Importing new keys

gpg --import keys/*.asc

echo Generating .sops.yaml

echo "creation_rules:" > .sops.yaml

FPS=($(gpg --import-options show-only --import keys/* | sed 's/^\s*//g' | grep '^[A-Z0-9]\{40\}$'))

if [[ ${#FPS[@]} -eq 1 ]]; then
  echo "   - pgp: ${FPS[-1]}" >> .sops.yaml
  exit 0
fi

# more than one key, use list

echo "  - pgp: >-" >> .sops.yaml

for fp in ${FPS[@]::${#FPS[@]}-1}; do
  echo "      $fp," >> .sops.yaml
done

echo "      ${FPS[-1]}" >> .sops.yaml
