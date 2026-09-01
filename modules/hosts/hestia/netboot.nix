{
        nixos.hosts.hestia = {
                services.pixiecore = {
                        enable = false; # TODO: work out how to get this onto a port other than 80.
                        openFirewall = true;
                        dhcpNoBind = true;
                        kernel = "https://boot.netboot.xyz";
                };
        };
}
