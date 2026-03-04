{
  lib,
  config,
  moduleLocation,
  ...
}:
let
  inherit (builtins)
    elemAt
    isFunction
    isAttrs
    mapAttrs
    attrValues
    ;
  inherit (lib)
    mkIf
    mkOption
    mkEnableOption
    types
    ;
  inherit (lib.attrsets)
    filterAttrs
    ;
  inherit (lib.strings) escapeNixIdentifier;

  # the module provided to `apply` seems to be nested two deep.
  # I don't know why, I don't know if this is always the case.
  unwrapModule = module: (elemAt (elemAt module.imports 0).imports 0);

  # rewrap replaces the module once it's been patched, dunno
  # how important this is; I dunno why there's two extra modules.
  rewrap =
    outer: inner:
    outer
    // {
      imports = map (
        middle:
        middle
        // {
          imports = [ inner ];
        }
      ) outer.imports;
    };

  # wraps the `config` block of a module with the condition.
  injectCondition =
    condition: module:
    if isFunction module then
      # Can't get the `config` block until it's called; so wrap it and try again later.
      args@{ pkgs, ... }: injectCondition condition (module args)
    else if isAttrs module && (module ? config || module ? options) then
      # If it has either `config` or `options` then it's a "full module".
      # prepend the conditional to the config if it exists and leave the rest.
      module
      // {
        config = mkIf condition (module.config or { });
      }
    else if isAttrs module then
      # Otherwise it's a "shorthand" module; extract the imports if they exist;
      # everything else is what would have been in "config".
      {
        imports = if module ? imports then module.imports else [ ];
        config = mkIf condition (filterAttrs (n: _: n != "imports") module);
      }
    else
      # Otherwise it 'sn't a module? maybe error instead?
      module;

  injectEnableOption =
    name: parent:
    { pkgs, config, ... }:
    let
      child = unwrapModule parent;
      patched = (injectCondition config.modules.optional.${name}.enable child);
      module = rewrap parent patched;
    in
    {
      # Dunno what this is; flake-parts had it.
      _file = "${toString moduleLocation}#modules.optional.${escapeNixIdentifier name}";
      options = {
        modules.optional.${name} = {
          enable = mkEnableOption "enable ${name} module";
        };
      };
      # imports = builtins.trace (elemAt (elemAt module.imports 0).imports 0) [ module ];
      imports = builtins.trace patched [ module ];
    };
in
{
  options =
    let
      # {nixos = ..., home-manager = ...}
      classes = types.lazyAttrsOf (types.deferredModule);
      aspects = types.lazyAttrsOf (classes);

    in
    {
      modules.optional = mkOption {
        type = types.lazyAttrsOf (types.deferredModule);
        apply = lib.mapAttrs injectEnableOption;
      };
      modules.enable = mkOption {
        type = types.lazyAttrsOf (types.deferredModule);
      };
      modules.nixos = mkOption {
        type = types.lazyAttrsOf (types.deferredModule);
      };
    };

  config = {
    modules.optional.all = {
      imports =
        with config.modules;
        [ enable.all ] ++ attrValues (filterAttrs (n: _: n != "all") optional);
    };
    modules.enable = mapAttrs (name: _: {
      modules.optional.${name}.enable = true;
    }) config.modules.optional;
  };
}
