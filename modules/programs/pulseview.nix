{
  nixos.programs.pulseview =
    {
      my,
      lib,
      pkgs,
      ...
    }:

    {
      programs.pulseview.enable = true;
      services.udev.enable = true;

      # This is a little bleh.
      users.users.oli.extraGroups = [
        "usb"
      ];
    };
}
