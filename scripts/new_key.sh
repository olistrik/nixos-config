#!/usr/bin/env bash

KEY=$USER@$(hostname)

FP=$(gpg --full-gen-key --quiet | sed -n 2p | xargs)

gpg --armor --export $FP > keys/$KEY.asc
