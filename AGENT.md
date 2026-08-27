# Project conventions

## Structure

**Non-flake** NixOS configuration using **npins** for pinning sources. No snowfall-lib, no flake-parts.

Self-referential `my` context via fixed-point recursion in `default.nix`:

```nix
# default.nix bootstraps:
my = {
  sources = (import ./npins) // args;
  lib = import ./lib.nix { inherit my; };
  pkgs = import ./packages.nix { inherit my; };
  modules = import ./modules.nix { inherit my; };
  hosts = import ./hosts.nix { inherit my; };
};
```

## Entrypoints

| File | Purpose |
|---|---|
| `./default.nix` | Bootstraps `my` context |
| `./lib.nix` | Custom lib functions, recursively loaded from `./lib/` |
| `./modules.nix` | Custom modules, shard-imported from `./modules/` |
| `./packages.nix` | Custom packages, callPackage'd from `./packages/` |
| `./hosts.nix` | NixOS host configs via `my.lib.mkHostsWith` |

## Module system

Files are recursively loaded from `./modules/` using `my.lib.importModules` (`lib/modules/import-sharded.nix`). Depth **3**: `<class>.<namespace>.<module>`.

- Files starting with `_` are excluded from auto-import.
- Auto imported files must contain a plain attrset.
- Multiple files defining the same attribute path are merged into one virtual module.
- Each leaf (depth 3) is a module for that class's module system. All three classes use the NixOS module evaluator internally; what differs is the context/specialArgs available to the module function.
- The module shorthand (bare attrset without a function wrapper) works when no parameters are needed — equivalent to `{ ... }: { /* attrset */ }`.
- You do not need to know how import-sharded.nix works; just accept that it does.

Classes in use:

| Class | Context (specialArgs) | Purpose |
|---|---|---|
| `nixos` | NixOS module | NixOS system config. `nixos.hosts.all` and `nixos.hosts.<hostname>` auto-imported |
| `nvf` | nvf module | Neovim configuration via nvf |
| `wrappers` | nix-wrapper-modules module | Program wrappers via nix-wrapper-modules |

The general convention is that importing a module is equivalent to enabling it; so if a module defines an `enable` option; it should default to true.

## NVF modules

The `nvf` class has two namespaces — `nvf.config.*` and `nvf.plugins.*` — both evaluated as nvf modules (same NixOS module system, `extraSpecialArgs` includes `my`).

Packages are built in `packages/wrapped/nvf.nix` via `nvf.lib.neovimConfiguration`, exported as `pkgs.wrapped.nvim.*`:

| Variant | Modules included |
|---|---|
| `pkgs.wrapped.nvim.minimal` | `base`, `keymaps`, `wayland` |
| `pkgs.wrapped.nvim.full` | minimal + `lsp`, `opencode` |
| `pkgs.wrapped.nvim.default` | alias for `full` |

### `nvf.config.*`

Per-feature configuration files in `modules/nvf/`. Each defines the full `nvf.config.<name>` attrset for that feature (options + keymaps). The sharded module system composes them.

### `nvf.config.keymaps`

Keymaps are sharded across feature files — each feature module that has keybindings also exports `nvf.config.keymaps` with its own mappings. The module system merges them automatically. There is no standalone keymaps file.

This is done so that others can use the config modules without opinionated or personal keymaps.

### `nvf.plugins.*`

Custom plugin modules or options not yet upstream in nvf. Files in `modules/nvf/plugins/`.


## Wrappers (nix-wrapper-modules)

Source: `github:BirdeeHub/nix-wrapper-modules` (pinned in npins).

Each wrapped program has two attrsets:

- `wrappers.programs.<name>` — module definition (options, defaults)
- `wrappers.config.<name>` — user configuration of that wrapper

This seperation of configuration allows `wrappers.programs.*` to be used by others without opinionated or personalized configuration.

Packages are built via `packages/wrapped/wrappers.nix` using `nix-wrapper-modules.lib.evalModules`, exported under `pkgs.wrapped.<name>`.

Build/run with `./run pkgs.wrapped.<name>`.

### Zsh wrapper specifics

`zshrc.content` is `lib.types.lines` → definitions from multiple modules **concatenate with `\n`**. For a non-merging string, use `types.str` (errors on conflict).

Component files in `modules/wrappers/zsh/`:

| File | Content |
|---|---|
| `base.nix` | `setopt` block, `stty`/noflowcontrol, zstyle completion matchers, `runtimePkgs`, `skipGlobalRC`, `promptInit` option definition |
| `aliases.nix` | All aliases and shell functions. Conditional guards via `if (( $+commands[program] ))` |
| `fzf.nix` | `upfind()`, `_fd()`, `_fzf_compgen_*`, fzf-share sourcing |
| `pay-respects.nix` | `_pr_esc_esc` widget + bindkey lines |
| `zoxide.nix` | `eval "$(zoxide init zsh)"` |

Starship prompt is handled via a `promptInit` option defined in `wrappers.programs.zsh` inside `base.nix`, set as `eval "$(starship init zsh)"`.

### Alacritty wrapper specifics

The Alacritty wrapper is at `modules/wrappers/alacritty.nix`. It has a `wrappers.config.alacritty` (user config) and `wrappers.programs.alacritty` (module definition ported from home-manager). Shell can be set via `config.wrappers.zsh.wrapper` to point at the wrapped zsh binary.

## Coding conventions

- `lib.getExe` preferred over `${pkgs.foo}/bin/foo` for single-binary packages.
- `lib.getExe'` when the binary name differs from the package name.
- `types.lines` for concatenated string options; `types.str` when merge conflicts should be errors.
- Conditional shell aliases use zsh's `if (( $+commands[program] ))` guard at runtime, not build-time checks.
- Prefer `lib.mkDefault` for user-facing defaults that should be overridable.
- Prefer `lib.mkOption` with explicit `type`, `default`, and `description` in program modules.

## User preferences (captured)

- Terminal: Alacritty (configured via wrapper)
- Shell: Zsh (wrapped)
- Prompt: starship
- Fuzzy finding: fzf
- Command correction: pay-respects (migrated from thefuck)
- Directory jumping: zoxide
- Editor: Neovim via nvf
- Wants aliases only defined if the target program exists at runtime
- Prefers `lib.getExe` over raw `${pkgs.foo}/bin/foo`
- Nix style: uses let-bindings for tool paths in zshrc content
- Machines: `thoth` and `hestia` (both NixOS), `muninn` (ubuntu + Nix), `huginn` (rpi debian + Nix).
- `muninn` and `huginn` use `my.pkgs` but are otherwise not described by this repo.
