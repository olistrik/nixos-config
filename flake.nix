{
  description = "Nix is love. Nix is life.";

  inputs = {
		##########################
		# nix package sets

    # Previous nixpkgs
    oldpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    # Normal nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    # Unstable nixpkgs
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

		##########################
		# flake and system support

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

		disko = {
			url = "github:nix-community/disko";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		impermanence.url = "github:nix-community/impermanence";

    templates.url = "github:nixos/templates";

		##########################
		# extras

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "unstable";
    };

    steam-fetcher = {
      url = "github:olistrik/steam-fetcher";
      inputs.nixpkgs.follows = "oldpkgs";
    };

    valheim-server = {
      url = "github:olistrik/valheim-server-flake";
      inputs = {
        nixpkgs.follows = "oldpkgs";
        steam-fetcher.follows = "steam-fetcher";
      };
    };


  };

  outputs = inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;

        src = ./.;

        snowfall = {
          namespace = "olistrik";
          meta = {
            name = "olistrik";
            title = "Flake stuff by Oli 😊";
          };
        };
      };
    in
    lib.mkFlake {
      channels-config = {
        allowUnfree = true;
      };

      nixvimModules = lib.snowfall.module.create-modules {
        src = ./modules/nixvim;
      };

      overlays = with inputs; [
        valheim-server.overlays.default
        steam-fetcher.overlays.default
        nixvim.overlays.default
      ];

      systems.modules.nixos = with inputs; [
				# not sure if I can provide it for all, or if I can only provided it for disko systems.
				# disko.nixosModules.default 
				impermanence.nixosModules.impermanence

        valheim-server.nixosModules.default

        # until I work out where to put this.
        ({ ... }: {
          nix.registry.nixpkgs.flake = nixpkgs;
          nix.registry.unstable.flake = unstable;
          nix.registry.olistrik.flake = self;
          nix.registry.templates.flake = self;

          nix.settings = {
            auto-optimise-store = true;
            substituters = [
              "https://cache.nixos.org"
            ];
            trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            ];
          };
        })
      ];
    };
}
