#!/usr/bin/env bash

if [[ -z "${ROOT}" ]]; then
  ROOT=/mnt
fi
if [[ -z "${DIR}" ]]; then
  DIR=/etc/nixos
fi

if [[ ${PWD} != $( echo ${ROOT}${DIR} | tr -s / ) ]]; then
  echo ${ROOT}${DIR} does not match \$PWD.
  echo Please set \$ROOT and \$DIR properly.
  exit 1
fi


# Print existing hosts.
echo hosts:
i=0
for D in hosts/*/; do
  name=$(basename $D)
  echo "  ($i) ${name}"
  i=$((i+1))
done

echo "  ($i) new host"

# Prompt user to choose host.
while true; do
  printf ": "
  read
  if [[ "${REPLY}" =~ ^[0-9]+$ ]] && [[ ${REPLY} -le $i ]] && [[ ${REPLY} -ge 0 ]]; then
    # User chose a valid option.
    break
  fi
  echo "please enter a number between 0 and $i"
done


if [[ ${REPLY} -lt $i ]]; then
  # if the user chose an existing host...
  echo linking configuration...

  for D in hosts/*/; do
    # find the host they chose.
    if [[ ${REPLY} -eq 0 ]]; then
      # link it.
      HOST=$(basename $D)
      break
    fi
    REPLY=$((REPLY-1))
  done
  if [[ ! -e hosts/${HOST}/configuration.nix ]]; then
    echo an error occured. hosts/${HOST}/configuration.nix does not exist.
    exit 1
  fi
  rm configuration.nix
  ln -s $ROOT/${DIR}/hosts/${HOST}/configuration.nix configuration.nix
else
  # if the user wishes to create a new host...
  # Prompt the user for the host name.
    echo "what is the name of this host?"
  while true; do
    printf ": "
    read
    if [[ ! -e hosts/${REPLY} ]]; then
      # the user has entered a valid host name.
      break
    fi
    echo "host name \"${REPLY}\" is alread in use. Please choose another." 
  done
  HOST=${REPLY}

  # Create the configuration and hardware-configuration for the host.
  echo "creating new configuration..."
  mkdir hosts/${HOST}
  nixos-generate-config --root ${ROOT} --dir ${DIR}/hosts/${HOST}
  
  # Allow user to edit the config.
  printf "Would you like to edit the configuration? (Y/n): "
  read
  if [[ "${REPLY,,}" != "n" ]]; then
    ${EDITOR} hosts/${HOST}/configuration.nix
  fi

  echo "linking new configuration..."
  rm configuration.nix
  ln -s $ROOT/${DIR}/hosts/${HOST}/configuration.nix configuration.nix
fi

echo "configuration is linked."
echo "root is at:  ${ROOT}"
echo "nixos is at: ${DIR}"
printf "would you like to install now? (Y/n): "
read
if [[ "${REPLY,,}" != "n" ]]; then
  if [[ "${DIR}" != "/etc/nixos" ]]; then
    echo "you have chosen to install these configurations somewhere other than
    /etc/nixos. You will need to install manually."
    exit 0
  fi
  nixos-install --root ${ROOT} --show-trace
  rm configuration.nix  
  ln -s ${DIR}/hosts/${HOST}/configuration.nix configuration.nix
  echo done! reboot whenever you are ready.
else
  echo done!
fi





