# Install and configure neovim + plugins.
{pkgs, lib, ...}:
let
  # the set of plugins to use.
  vimPlugins = pkgs.vimPlugins // pkgs.unstable.vimPlugins // pkgs.kranex.vimPlugins;

  # Plugins that have configurations attached.
  configuredPlugins = import ./configuredPlugins.nix {inherit pkgs; inherit vimPlugins;};

  # Language support configurations and plugins.
  # languages = import ./languages.nix {inherit pkgs; inherit vimPlugins; inherit lib;};

  # The configured plugins I actually want to use.
  plugins = with configuredPlugins; [
    colorscheme

    telescope
    nerdtree

    treesitter
    ts-autotag

    lspconfig
    compe
    rust
  ];

  # Extra plugins that either don't need configuration or I haven't configured yet.
  unconfiguredPlugins = with vimPlugins; [
    vim-gitgutter
    vim-repeat
    auto-pairs
    vim-surround
    vim-nix

    vim-wakatime
  ];

  # '"path/to/plugin_a.lua", "path/to/plugin_b.lua"'
  sourcePluginConfigs = builtins.concatStringsSep "\n" (
      builtins.map (x: "source ${x}") (builtins.catAttrs "config" plugins)
  );

in {
  # Add in all the dependencies that some languages have (also some plugins have
  # "optional?" dependencies that nix won't add).
  # TODO: I want to use a wrapper for this so they don't all endup on my path.
  environment.variables.EDITOR = "nvim";
  environment.systemPackages = with pkgs; [
    (unstable.neovim.override {
      configure = {
        # Merge the selected configured plugins, any extras from them and the
        # unconfigured plugins.
        plug.plugins = (
          builtins.catAttrs "plugin" plugins ++
          builtins.concatLists (builtins.catAttrs "extras" plugins) ++
          unconfiguredPlugins
        );
        # Merge the configs from all the configured plugins and the main neovim
        # config.
        customRC = ''
        source ${./configs/init.lua}
        ${sourcePluginConfigs}
        '';
      };
    })
  ] ++ builtins.concatLists (builtins.catAttrs "requires" plugins);


  # environment.systemPackages = builtins.concatLists (builtins.catAttrs "requires" plugins);
  # programs.neovim = {
  #   enable = true;
  #   package = pkgs.unstable.neovim-unwrapped;

  #   defaultEditor = true;
  #   viAlias = true; # vi is actually useful when neovim breaks.
  #   vimAlias = true;

  #   # Merge all the runtime attrsets from all the selected configuredPlugins.
  #   runtime = lib.fold (x: y: lib.mergeAttrs x y ) {} (builtins.catAttrs "runtime" plugins);

  #   configure = {
  #     packages.myPlugins = {
  #       opt = [];
  #       start =
  #         builtins.catAttrs "plugin" plugins ++
  #         builtins.concatLists (builtins.catAttrs "extras" plugins) ++
  #         unconfiguredPlugins;
  #     };
  #     customRC =
  #       (builtins.concatStringsSep "\n" (builtins.catAttrs "config" plugins)) +
  #       builtins.readFile ./config.vim;
  #   };
  # };
}
