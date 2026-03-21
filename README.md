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


## [self.nix](./self.nix)

Before I go into details about each of the entrypoints, I will first explain
the `self` context. [self.nix](./self.nix) sets up the shared context for all
of my entrypoints. I got tired writing it out every time so I wrapped it up
into a function. It more or less functions as `inputs` + `self` from flakes, so
if you want to use any of my modules, wrappers, or packages you'll likely want
to instantiate `self` manually, and override at least nixpkgs using the
`override` argument.

I'd like to move the fixed point recursion of `lib` up into `self` as this
should simplify things across all the entrypoints. I'm also not overly happy
with the name `self` as other module systems such as `nvf` use it, so for those
I use `_` instead. At somepoint I'll come up with a better name and unify it.

# Entrypoints

Unlike flakes, there are several entrypoints to this repo, each can be used
independently, and import eachother as necessary.

## [default.nix](default.nix)

A convenience wrapper exposing `lib`, `modules`, `hosts`, and `packages` from
the other entrypoints. Useful when you want everything at once.

## [hosts.nix](./hosts.nix)

Returns an attrset of `nixosSystems`, one for each machine. Currently defines
`thoth` and `hestia`. Machines are built using `self.lib.mkHostsWith`, which
bootstraps `lib.evalConfig` with `self` included via the specialArgs,
automatically imports the modules `nixos.hosts.all` and
`nixos.hosts.<hostname>`, and sets `networking.hostName` to `<hostname>`.

## [lib.nix](./lib.nix)

Returns a nested attrset of my custom lib functions, recursively loaded from
`./lib/`. Each file can declare it's own namespace within lib which may be
arbitrarily deep. These are all merged into a single attrset using
`lib.recursiveUpdate`. `lib.fix` is used for fixed-point recursion so functions
can reference each other.

## [modules.nix](./modules.nix)

Returns a structured attrset of my custom modules. Modules are imported
recursively using [`self.lib.importModules`](./lib/modules/import-sharded.nix),
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
- `nvf.keybinds.*` is for _my_ keybindings for a plugin (custom or otherwise).

### wrappers

- `wrappers.programs.*` is for custom wrapper modules not (yet) part of
[nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules).
- `wrappers.my.*` is for _my_ configurations of a wrapper (custom or
otherwise).

## [nvf.nix](./nvf.nix)

Returns an attrset of Neovim configurations built with
[nvf](https://github.com/notashelf/nvf), using my modules. Currently provides
`nvim-minimal` (just base, keymaps, and wayland support) and `nvim-full` (adds
LSP and opencode support). The `default` alias points to `nvim-full`.

I wouldn't recommend using this directly, but it serves as a good example of
how you _could_ integrate my `nvf.plugins.*` or `nvf.config.*` modules.

## [packages.nix](./packages.nix)

Returns a nested attrset of all my custom packages from `./packages/`. Leaf
functions are called with `callPackage`. Also merges in the outputs of
`wrappers.nix` and `nvf.nix` under a `wrapped` key for convenience.

## [wrappers.nix](./wrappers.nix)

Returns an attrset of wrapped programs using
[nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules).
Wrappers are evaluated by importing modules from `self.modules.wrappers.my`.
Each wrapper is built using `nix-wrapper-modules.evalModules` with access to
`self` as a special argument.
