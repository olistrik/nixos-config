{
  description = "Nix is love. Nix is life.";

  inputs = {

    # Normal nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    # Unstable nixpkgs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";

    # templates
    templates.url = "github:nixos/templates";

    # iso generator
    nixos-generators.url = "github:nix-community/nixos-generators";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-generators, ... }@inputs:
    let
      # overlays on nixpkgs.
      overlay-unstable = (final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (final) system;
          config.allowUnfree = true;
        };
      });

      overlay-olistrik =
        (final: prev: { olistrik = final.callPackage ./packages { }; });

      modules-olistrik = import ./modules;

      # modules that are shared between all hosts.
      commonModules = [
        ({ ... }: {
          nixpkgs.overlays = [ overlay-unstable self.overlays.default ];
          nixpkgs.config.allowUnfree = true;

          nix.registry.nixpkgs.flake = nixpkgs;
          nix.registry.unstable.flake = nixpkgs-unstable;
          nix.registry.olistrik.flake = self;
          nix.registry.templates.flake = self;
        })

        modules-olistrik

		home-manager.nixosModules.home-manager

        ./shared/default.nix # default programs and config for all systems.
      ];

    in {
      # My systems.
      nixosConfigurations = {
        ## Work Lenovo E15
        nixogen = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules ++ [ ./hosts/nixogen/configuration.nix ];
        };

        ## Home Server
        hestia = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules ++ [
            (nixpkgs-unstable + /nixos/modules/services/audio/wyoming/piper.nix)
            (nixpkgs-unstable
              + /nixos/modules/services/audio/wyoming/faster-whisper.nix)
            (nixpkgs-unstable
              + /nixos/modules/services/audio/wyoming/openwakeword.nix)
            ./hosts/hestia/configuration.nix
          ];
        };

        ## Live USB
        liveUsb = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules = commonModules ++ [ ./hosts/live-usb/configuration.nix ];
          format = "install-iso";
        };
      };

      overlays = {
        default = overlay-olistrik;
        olistrik = overlay-olistrik;
      };

      templates = inputs.templates.templates // import ./templates;
      defaultTemplate = self.templates.devshell;
    };
}
