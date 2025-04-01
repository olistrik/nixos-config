
# NixOS à la Oli

This repository describes my personal NixOS configuration, modules, and
packages.

I've experimented over the years with various methods, from bare flakeless
NixOS configurations, to [flake-parts](https://flake.parts/). Ultimately I've
settled on [snowfall-lib](https://github.com/snowfallorg/lib) as it does a huge
amount of the legwork for me and while I don't always agree with the decisions
of opinionated frameworks, it definitely takes away a lot of the thinking on my
part and just lets me write the fun bits.

I'm not going to explain how snowfall works in detail, if you've come to this
repository looking for inspiration and haven't heard of it, [the documentation
can be found here](https://snowfall.org/guides/lib/quickstart/). In short,
snowfall automatically produces my flake outputs through an opinionated folder
structure. 

Some quick gotchas to save you some time;

- There's almost certainly stuff in the `lib` folder that I've written (or
borrowed) that I am using frequently. If you see anything and are wondering
"wtf is `enabled`" or "I didn't realise I could do `mkOpt` instead of
`mkOption`" then there's a good chance it's from there. Check the top of the
file for `with lib.olistrik`.
- The `modules/nixos` folder is exposed to all of my NixOS hosts automatically
under the namespace `olistrik`. I try to namespace everything.
- My nixvim config has moved to
[olistrik/nixvim-config](https://github.com/olistrik/nixvim-config). Sorry if
you came here looking for that. 


## How to use my Packages

If for some reason you'd like to use my packages, you're more than welcome to
do so. However, keep in mind all the risks that come with that. This is like my
own little personal AUR. That said, I neither want to package nor distribute
malicious code, so if you notice that one of my packages is bad or out-of-date,
please let me know.

Otherwise, using my packages is pretty straight forward. Just add my default
overlay to your nixpkgs and your done. Here's an example of a devshell with my
base nixvim:

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  # add my repo as an input.
  inputs.olistrik.url = "github:olistrik/nixos-config";

  outputs = { flake-utils, nixpkgs, olistrik, ... }: 
    flake-utils.lib.eachDefaultSystem (
        system: let
            pkgs = import nixpkgs {
                inherit system; 
                # add the default overlay to your nixpkgs.
                overlays = [ olistrik.overlays.default ];
            }; 
        in {
            devShell = pkgs.mkShell {
                # use it! 
                packages = with pkgs; [ olistrik.nixvim ];
            };
        };
    );
}
```

All of my packages additionally expose individual overlays, and are also
exported through the packages output for every standard architecture, however I
only use x86-64_linux so your mileage may vary on darwin or aarch64.

Thus there are numorous ways you can use them, including the classic `nix run "github:olistrik/nixos-config#nixvim"`.

## My module organization

I'll document this later. Honestly though, they're mine. You probably shouldn't
use them.

## My Nixvim configuration 

Has moved to
[olistrik/nixvim-config](https://github.com/olistrik/nixvim-config). Namely
because it was becoming quite frustrating that small changes required
rebuilding my entire system. Moving it hasn't really changed that, arguably it
has made it worse, as any changes I make there now require updating the
`flake.lock` here in-order for them to persist system-wide.

# Installation notes

This is mainly for me, you probably don't want to be installing my systems
yourself. I currently have two systems configured using this repository; my
personal laptop and daily driver Thoth, and my home server Hestia which hosts
everything from home automation applications to steam game servers.

### Build Live USB

This flake exports an x86-64_install_iso image that is preconfigured with git,
flake support, nixvim, and to accept my laptops SSH key.

Build it, burn it, and boot it _in UEFI mode_. 

### Format SSD or HDD

Do what you want, luks, zfs, fat12. Get it all mounted to /mnt. I usually use 
[disko](https://github.com/nix-community/disko) for this, [Thoth](./systems/x86_64-linux/thoth/disko-configuration.nix) being a principle this.

In summary though:

#### sdx1 

512MB EFI, mounted to `/mnt/efi`. 
!! This is recommended by systemd, but requires `boot.loader.efi.efiSysMountPoint = "/efi"` !!

#### optional: sdx2

A ~32GB swap partion if I'm using ZFS, otherwise I skip this just use a swap file.

#### sdxN

I use the rest of the drive as a single `/` partition, I don't bother splitting 
partitions off for everything else.

### Install

For any host other than my main, I don't bother cloning the repo anymore. I
just use `rebuild --target <host>` from Thoth. Naturally though, that isn't
possible when doing a clean install of Thoth, in that scenario I clone this
repo to `/persist/nixos` and install it using `./rebuild` directly.


I haven't worked out yet how to keep the `hardware-config.nix` out of the repo
and only on the host, given how flakes work I doubt it's possible or desirable.
Thus I must generate it on the target host and copy it back to Thoth.

```
nixos-generate-config

# scp the hardware config back to Thoth, setup and push the new host.

nixos-install --flake "github:olistrik/nixos-config#<hostname>"

reboot
```

If the host needs secrets, it'll need a nixwarden access token which I usually
place in `/var/lib/nixwarden/nixwarden.key`.

Nixwarden is another yet another WIP in dire need of renovation and documentation.

### Updating

I only keep this repo on Thoth, any changes there with or without pushing I can
install on all my tailscale connected hosts with:

```
rebuild switch --target hostname
```

TODO: 

- rebuild switch --all

