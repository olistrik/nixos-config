# Install and configure neovim + plugins.
{ pkgs, lib, ... }:
let
  basePackages = pkgs;
  # the set of plugins to use.
  vimPlugins = basePackages.vimPlugins
    // (lib.getAttrs [ "nvim-tree-lua" ] pkgs.unstable.vimPlugins);

  # Plugins that have configurations attached.
  configuredPlugins = import ./plugins.nix {
    inherit (basePackages) pkgs;
    inherit vimPlugins;
  };

  # Language support configurations and plugins.
  # languages = import ./languages.nix {inherit pkgs; inherit vimPlugins; inherit lib;};

  # The configured plugins I actually want to use.
  plugins = builtins.attrValues configuredPlugins;

  pluginPkgs = let
    plugs = builtins.catAttrs "plugin" plugins;
    transitiveClosure = plugin:
      [ plugin ] ++ (lib.unique (builtins.concatLists
        (map transitiveClosure plugin.dependencies or [ ])));

    deps = lib.concatMap transitiveClosure plugs;
    pkgs = lib.unique (plugs ++ deps);
  in pkgs;

  sourceStr = with builtins;
    concatStringsSep "\n"
    (map (x: "require('kranexconf.${x}')") (catAttrs "config" plugins));

  externals = with pkgs;
    [ xclip ] ++ builtins.concatLists (builtins.catAttrs "extern" plugins);

  # Extra plugins that either don't need configuration or I haven't configured yet.
  # unconfiguredPlugins = with vimPlugins; [
  #   vim-gitgutter
  #   vim-repeat
  #   auto-pairs
  #   vim-surround
  #   vim-nix

  #   # vim-wakatime
  # ];
in (basePackages.neovim.override {
  configure = {
    packages.default.start =
      builtins.trace "${builtins.foldl' (x: y: x + y + "\n") "" pluginPkgs}"
      pluginPkgs;
    customRC = ''
      set runtimepath^=${./config}
      source ${./config/lua/init.lua}

      lua <<EOF
      ${sourceStr}
      EOF
    '';
  };
}).overrideAttrs (_: { passthru.additionalPackages = externals; })
