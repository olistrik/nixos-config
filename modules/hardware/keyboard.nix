{
  nixos.hardware.keyboard =
    { pkgs, ... }:
    {
      hardware.keyboard.qmk.enable = true;
      environment.systemPackages = with pkgs; [ via ];
      services.udev.packages = with pkgs; [ via ];
      users.users.oli.extraGroups = [ "plugdev" ];
    };
}
