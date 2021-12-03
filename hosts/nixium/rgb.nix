{config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    openrgb
    i2c-tools
  ];

  hardware.i2c.enable = true;

  # systemd.services.openrgbBoot = {
  #   wantedBy = [ "multi-user.target" "suspend.target" ];
  #   after = [ "suspend.target" ];
  #   script = ''
  #     echo setting strips to length 16
  #     ${pkgs.openrgb}/bin/openrgb -d 4 -z 1 -s 16 -z 2 -s 16

  #     echo setting RGB to off white 8899FF
  #     ${pkgs.openrgb}/bin/openrgb -c 8899FF
  #   '';
  # };
}
