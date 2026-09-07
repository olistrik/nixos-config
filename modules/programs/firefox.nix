{
        nixos.programs.firefox =
                { pkgs, ... }:
                let
                        inherit (pkgs) firefoxpwa;
                in
                {
                        environment.systemPackages = [
                                firefoxpwa
                        ];

                        programs.firefox = {
                                enable = true;
                                nativeMessagingHosts.packages = [
                                        firefoxpwa
                                ];
                        };
                };
}
