> [!IMPORTANT]
> I've reciently migrated from flakes to bare nix with npins. I've also noticed
> this repo gets a suprising number of clones which I'm assuming is just bots
> being botty. However, if I've broken your flake config (sorry about that),
> you can fix it by pointing the input at the
> [legacy-flakes](https://github.com/olistrik/nixos-config/tree/legacy-flakes)
> branch.

My Nix configurations for anything I can put nix on. I've used flakes and
snowfall-lib in the past, but I've become quite tired of complex behavior being
hidden away in dependencies and my entire repo being copied into the store.

I briefly tried out a [dendritic
configuration](https://github.com/mightyiam/dendritic) using flake parts, which
inspired what I am using in this repository, importantly though my modules are
_not_ wrapped in modules. I feel that it's totally unnecessary, and while it's
cool that you can write any output of your flake in anyfile in any location, it
doesn't really promote good practices. Yes, you can now write your nixosModule,
homeManagerModule, package, and overlay for alacritty all in a single file. But
_should_ you?

Plus, flake-parts modules incorrectly handles module keys, which prevents
`evalModules` from deduplicating imports. [There's been an issue detailing it
for over a year now](https://github.com/hercules-ci/flake-parts/issues/299). I
could make a PR and fix it, or I could just not be dependent on another library
for a dozen or so lines of arguably simple nix code.


# Entrypoints

Unlike flakes, there are several entrypoints to this repo and each can be used
independently. However as they all import the `default.nix`, there's really not
much point in using them that way.

All the entrypoints are functions which accept an attrset of sources to
override my own. They can also be provided with a `my` context, but this should
typically be avoided as this is used by [`default.nix`](./default.nix) to bootstrap itself.

## [default.nix](default.nix)

This is the main entrypoint. It uses the magic of `let` and fix-point recusion
to instantiate the `my` context with all the outputs of this repo, while also
providing the `my` context to said outputs. This is how `lib` functions and
`modules` can reference eachother.

## [hosts.nix](./hosts.nix)

Returns an attrset of `nixosSystems`, one for each machine. Currently defines
`thoth` and `hestia`. Machines are built using `my.lib.mkHostsWith`, which
bootstraps `lib.evalConfig` with `my` included via the specialArgs,
automatically imports the modules `nixos.hosts.all` and
`nixos.hosts.<hostname>`, and sets `networking.hostName` to `<hostname>`.

## [lib.nix](./lib.nix)

Returns a nested attrset of my custom lib functions, recursively loaded from
`./lib/`. Each file can declare it's own namespace within lib which may be
arbitrarily deep. These are all merged into a single attrset using
`lib.recursiveUpdate`.

## [modules.nix](./modules.nix)

Returns a structured attrset of my custom modules. Modules are imported
recursively using [`my.lib.importModules`](./lib/modules/import-sharded.nix),
mirroring how flake-parts imports sub-modules. However, files are expected to
be attrsets (not modules), and uses an extended module path;
`<class>.<namespace>.<module>`.

Modules can be declared at any depth in `./modules`, in any file, and even
split across files. [`importModules`](./lib/modules/import-sharded.nix) will
merge multiple definitions of the same module path. any file or folder
beginning with an underscore is not recursively imported.

Ideally, I'd like to eventually support arbitrarily deep attrsets, but this
poses some challenges with the various ways modules can be declared.

Currently, I'm using a number of classes, and each has a handful of special
modules and namespaces.

### nixos

- `nixos.hosts.all` is included in all hosts automatically.
- `nixos.hosts.<hostname>` is included automatically on the matching host.
- `nixos.hosts.none` is for broken configs and should never be included.
- `nixos.*.*` is then a mix of custom modules and configurations. These are not
imported automatically.

### nvf

- `nvf.plugins.*` is for custom nvf plugins or options that aren't (yet) part
of [nvf](https://github.com/notashelf/nvf).
- `nvf.config.*` is for _my_ configuration of a plugin (custom or otherwise).
- `nvf.config.keymaps` is for all keybindings.

### wrappers

- `wrappers.programs.*` is for custom wrapper modules not (yet) part of
[nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules).
- `wrappers.config.*` is for _my_ configurations of a wrapper (custom or
otherwise).

## [packages.nix](./packages.nix)

Returns a nested attrset of all my custom packages from `./packages/`. Leaf
functions are called with `callPackage`.

`./packages/wrapped` is a special case; this exports the final packages for my
`nix-wrapper-modules` under `pkgs.wrapped.*`, and my `nvf` configurations under
`pkgs.wrapped.nvim.*`.

This is currently a work in progress, I'd like to make this more automatic as I
have with lib and modules.

# Examples

## shell.nix

Here is a simple shell using npins with my full nvim config.

```nix
let
  sources = import ./npins;
  # npins add channel nixos-25.11 --name nixpkgs
  pkgs = import sources.nixpkgs { };
  # npins add github olistrik nixos-config --name olistrik
  olistrik = import sources.olistrik {
    # optional; equivalent to `flake.inputs.nixpkgs.follows`;
    inherit (sources) nixpkgs;
  };

in
pkgs.mkShell {
  packages = with olistrik.pkgs; [
    wrapped.nvim.full
  ];
}
```

