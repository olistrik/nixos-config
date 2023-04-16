{
  description = "Nix is love. Nix is life.";

  inputs = {

    # Normal nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";

    # Unstable nixpkgs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # nix2vim
    #nix2vim = {
    #  url = "github:kranex/nix2vim";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    devenv = {
      url = "github:cachix/devenv/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake utils
    flake-utils.url = "github:numtide/flake-utils";

    # templates
    templates.url = "github:nixos/templates";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    with flake-utils.lib;
    let
      # might want these in the future.
      # inherit (builtins) toPath;
      # inherit (nixpkgs) lib;
      # inherit (lib) genAttrs;

      # overlays on nixpkgs.
      nixpkgsConfig = with inputs; rec {
        config = { allowUnfree = true; };
        overlays = [
          (final: prev: {
            # pkgs.unstable
            unstable = import nixpkgs-unstable {
              inherit (prev) system;
              inherit config;
            };
            # pkgs.kranex
            kranex = final.callPackage ./pkgs { };
            devenv = devenv.packages."${prev.system}".devenv;
          })
          # inputs.nix2vim.overlay
        ];
      };

      pin-flake-reg = with inputs; {
        nix.registry.nixpkgs.flake = nixpkgs;
        nix.registry.unstable.flake = nixpkgs-unstable;
        nix.registry.kranex.flake = self;
        nix.registry.templates.flake = self;
      };

      # modules that are shared between all hosts.
      commonModules = with self.modules; [
        ({ nixpkgs = nixpkgsConfig; })
        pin-flake-reg # pin the pkgs.

        ./shared/default.nix # default programs and config for all systems.

        programs.alacritty
      ];

      # shortcut for x86-64 linux systems.
      linux64 = host:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules
            ++ [ (./. + "/hosts/${host}/configuration.nix") ];
        };
    in {
      # My systems.
      nixosConfigurations = {
        ## Work Lenovo E15
        nixogen = linux64 "nixogen";
        ## Home Desktop
        nixium = linux64 "nixium";
        ## WSL 2
        winix = linux64 "winix";
      };

      # My modules, see commonModules for usage.
      modules = import ./modules;

      templates = inputs.templates.templates // import ./templates;
      defaultTemplate = self.templates.devshell;

    } // eachDefaultSystem (system: {
      # My packages, see nixpkgsConfig for usage.
      packages = flattenTree (import nixpkgs {
        inherit system;
        inherit (nixpkgsConfig) config overlays;
      }).kranex;
    });
}
