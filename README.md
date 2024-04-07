
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
repository looking for insperation and haven't heard of it, [the documentation
can be found here](https://snowfall.org/guides/lib/quickstart/). Otherwise,
tldr, snowfall automatically produces my flake outputs through an opinionated
folder structure. 

Some quick gotchas to save you some time;

- There's almost certainly stuff in the `lib` folder that I've written (or
  borrowed) that I am using frequently. If you see anything and are wondering
  "wtf is `enabled`" or "I didn't realise I could do `mkOpt` instead of
  `mkOption`" then there's a good chance it's from there. Check the top of the
  file for `with lib.olistrik`.
- The `modules/nixos` folder is exposed to all of my NixOS hosts automatically
  under the namespace `olistrik`. I try to namespace everything.
- My nixvim config is _wild_. I've set it up so I can install a barebones nvim
  editor globally, and for each project I extend that base with language and
  project specific configuration. It's the nix edition of exrc.  


## How to use my Packages

If for some reason you'd like to use my packages, you're more than welcome to
do so. However, keep in mind all the risks that come with that. This is like my
own little personal AUR. That said, I neither want to package nor distribute
malicious code, so if you notice that one of my packages is bad or out-of-date,
please let me know.

Otherwise, using my packages is pretty streight forward. Just add my default
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

## My Nixvim 

Again, I'll get to this later. In summary though, I have nixvim in a module,
but it's actually installed and exposed as a package using
`nixvim.makeNixvimWithModule`. This sets up my base config, and in each of my
projects I use `olistrik.packages.nixvim.nixvimExtend` to add LSP support and
per project/language configuration.

# Installation notes

This is mainly for me, you probably don't want to be installing my systems
yourself. 

### Build Live USB

This flake exports an x86-64_install_iso image that is preconfigured with git,
flake support, nixvim, and to accept my laptops SSH key.

Build it, burn it, and boot it _in UEFI mode_. 

### Format SSD or HDD

Do what you want, luks, zfs, fat12. Get it all mounted to /mnt.

This is my standard:

#### sdx1 

512MB EFI, mounted to `/mnt/efi`. 
!! This is recommended by systemd, but requires `boot.loader.efi.efiSysMountPoint = "/efi"` !!

#### sdx2

Everything else, mounted to `/mnt`.
I Don't really bother with seperate swap anymore. If I need it I use a swapfile.

### Install

For any host other than my main, I don't bother cloning the repo anymore. I
just use `rebuild --target <host>` from my main. Ofcourse, can't do that for
the first install. I haven't worked out how to keep the hardware-config.nix out
of the repo and only on the host.

```
nixos-generate-config

# scp the hardware config back to main, setup and push the new host.

nixos-install --flake "github:olistrik/nixos-config#<hostname>"

reboot
```

If the host needs secrets, it'll need a nixwarden access token.
It will also need to be connected to tailscale.

### Updating

I only keep this repo on my laptop, any changes there with or without pushing
I can install on all my tailscale connected hosts with:

```
rebuild switch --target hostname
```

TODO: 

- rebuild switch --all

