{
  description = "Nix is love. Nix is life.";

  inputs = {
    ##########################
    # nix package sets

    # Normal nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

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

    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    steam-fetcher = {
      url = "github:nix-community/steam-fetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    valheim-server = {
      url = "github:hamburger1984/valheim-server-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        steam-fetcher.follows = "steam-fetcher";
      };
    };

    nix-matlab = {
      url = "gitlab:doronbehar/nix-matlab";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    minimal-tmux = {
      url = "github:niksingh710/minimal-tmux-status";
      inputs.nixpkgs.follows = "nixpkgs";
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
        niri-flake.overlays.niri
        nix-matlab.overlay # why.
      ];

      # Temporary, immich is not in 24.05
      # systems.hosts.hestia.modules = with inputs; [
      #   ({ ... }: {
      #     disabledModules = [ "services/databases/redis.nix" ];
      #     imports = [
      #       "${unstable}/nixos/modules/services/web-apps/immich.nix"
      #       "${unstable}/nixos/modules/services/databases/redis.nix"
      #     ];
      #   })
      # ];

      systems.modules.nixos = with inputs; [
        disko.nixosModules.default
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
              "https://cache.olii.nl"
              "https://cache.nixos.org"
            ];
            trusted-public-keys = [
              "cache.olii.nl:/eobpj1e29xJJ4r2ixYFR4E0t0zNDqu2g9/3ryaRa60="
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            ];
          };
        })
      ];
    };
}
