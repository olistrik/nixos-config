{
  nixos.services.printing = {
    # Enable printing service. It doesn't work very well though.
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
