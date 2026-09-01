{
        nixos.hosts.hestia = {
                services.pixiecore = {
                        enable = true;
                        openFirewall = true;
                        dhcpNoBind = true;
                        kernel = "https://boot.netboot.xyz";
                };
        };
}
