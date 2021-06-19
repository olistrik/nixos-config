#!/usr/bin/env bash


KEY=$USER@$(hostname)

# gpg --delete-secret-key $KEY
# gpg --delete-key $KEY

FP=$(gpg --generate-key --batch << EOF 2> >(grep -Eow '[A-Z0-9]{40}')
%no-protection
Key-Type: RSA
Key-Length: 4096
Name-Real: NixOS Secrets
Name-Email: $KEY
Expire-Date: 0
%commit
EOF
)

echo fingerprint: $FP

gpg --armor --export $FP > keys/$KEY.asc
