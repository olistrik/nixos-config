# notes on nix installing

# Enable WIFI on CD

```
wpa_passphrase [SSID] [PASSWORD] > /etc/wpa_supplicant
systemctl start wpa_supplicant
```

# LUKS Encryped ThinkPad

1. get the storage correctly partitioned.

  - 512MB FAT : /boot/efi
  - The rest a LVM partition:

    ```
    cryptsetup luksFormat /dev/[LVM_Partition]
    cryptsetup luksOpen /dev/[LVM_Partition] env-pc

    pvcreate /dev/mapper/enc-pv
    vgcreate vg /dev/mapper/enc-pv
    lvcreate -L [SWAP_SIZE]G -n swap vg
    lvcreate -l '100%FREE' -n root vg

    mkfs.fat /dev/[EFI_PARTITION]
    mkfs.ext4 -L root /dev/vg/root
    mkswap -L swap /dev/vg/swap
    ```

2. prep partition for install like normal:

    ```
    mount /dev/vg/root /mnt
    mkdir /mnt/boot
    mount /dev/[EFI_PARTITION] /mnt/boot
    swapon /dev/vg/swap
    ```

3. setup hosts. First `nix-shell -p nixUnstable git`

  a. if its a new host:

    ```
    nixos-generate-config --root /mnt
    cd /mnt/etc
    mv nixos nixos-old
    git clone git@github.com:kranex/nixos-config.git nixos
    mv nixos-old nixos/hosts/[NEW_HOSTNAME]
    ```

    Then set up the bootloader and luks stuff like `hosts/nixogen`, you can probably nick the configuration entirely. Just check the UUID in the luks stuff.

    Add a host to the `flake.nix`

  b. if it's an existing host and the file system hasn't changed:

    ```
    cd /mnt/etc
    git clone git@github.com:kranex/nixos-config.git nixos
    ```


4. create secrets/default.nix:

    ```
    {
      username = {
        hashedPassword = "";
      };
    }
    ```
  hashedPasswords can be generated using `mkpasswd -m sha-512 > my_hashed_passwd`

  NOTE: You may need to change the path of the sectrets dir temporarily to /mnt/etc/nixos/secrets

5. finally install:

    ```
    nixos-install --flake git@github.com:Kranex/nixos-config.git#[HOSTNAME]
    ```
