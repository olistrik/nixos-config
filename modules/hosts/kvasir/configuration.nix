{
        nixos.hosts.kvasir =
                { my, pkgs, ... }:
                {
                        imports = with my.modules.nixos; [
                                ./_hardware-configuration.nix

                                hardware.touchpad
                                hardware.keyboard
                                hardware.fingerprint

                                collections.personal
                                collections.workstation

                                programs.nix-ld

                                programs.niri
                                programs.ags
                                programs.pulseview

                                system.virtualisation
                                system.agenix
                                system.plymouth
                                system.impermanence
                        ];

                        age.identityPaths = [ "/persist/age/kvasir-identity" ];
                        environment.shellAliases.agenix = "agenix -i /persist/age/kvasir-identity";

                        # Make the real GPU framebuffer available in the initrd so
                        # Plymouth is visible before the LUKS prompt appears.
                        boot.initrd.kernelModules = [ "amdgpu" ];

                        environment.systemPackages = with pkgs; [
                                slack

                                firefoxpwa

                                nodejs

                                # (my.pkgs.mkPakeApp {
                                #         url = "https://researchable.simplicate.app";
                                #         name = "Simplicate";
                                #         icon = pkgs.fetchurl {
                                #                 url = "https://researchable.simplicate.app/favicon.png"; # or wherever their actual icon lives
                                #                 hash = "sha256-xDfWBCkPl1Hh8Zr/mXtDn4ORCNOP9BJVDh8GH3vNAqg=";
                                #                 name = "simplicate-icon.png";
                                #         };
                                # })
                        ];

                        networking.hostId = "007f0200";
                        system.stateVersion = "26.05";
                };
}
