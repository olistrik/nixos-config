{
  description = "Nix is love. Nix is life.";

  inputs = {
    ##########################
    # nix package sets

    # Normal nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

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

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
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

    astal = {
      url = "github:aylur/astal/0507a6bf1035ddbe72fdb64c0fb5dc1c991faeaf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:aylur/ags/3ed9737bdbc8fc7a7c7ceef2165c9109f336bff6";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        astal.follows = "astal";
      };
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    nixvim-config = {
      url = "github:olistrik/nixvim-config";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        unstable.follows = "unstable";
        snowfall-lib.follows = "snowfall-lib";
      };
    };

    steam-fetcher = {
      url = "github:nix-community/steam-fetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    valheim-server = {
      url = "github:olistrik/valheim-server-flake";
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

    nix-search = {
      url = "github:diamondburned/nix-search";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tailscale-forward-auth = {
      url = "github:olistrik/tailscale-forward-auth";
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

      overlays = with inputs; [
        tailscale-forward-auth.overlays.default
        valheim-server.overlays.default
        # steam-fetcher.overlays.default
        nixvim-config.overlays.default

        niri-flake.overlays.niri

        # why non-standard?
        nix-matlab.overlay
        steam-fetcher.overlay
      ];

      # Add wsl modules for loki.
      systems.hosts.loki.modules = with inputs; [
        nixos-wsl.nixosModules.default
      ];

      systems.hosts.hestia.modules = with inputs; [
        ({
          # WARN: REMOVE IN 25.11
          disabledModules = [ "services/web-apps/nextcloud.nix" ];
          imports = [ "${unstable}/nixos/modules/services/web-apps/nextcloud.nix" ];
        })
      ];

      systems.modules.nixos = with inputs; [
        disko.nixosModules.default
        impermanence.nixosModules.impermanence

        valheim-server.nixosModules.default
        tailscale-forward-auth.nixosModules.default

        # until I work out where to put this.
        ({ ... }: {

          nix.registry = {
            nixpkgs.flake = nixpkgs;
            unstable.flake = unstable;
            olistrik.flake = self;
            templates.flake = self;
          };

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
