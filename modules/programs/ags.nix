{
  nixos.programs.ags =
    {
      self,
      lib,
      pkgs,
      ...
    }:
    let
      extraPackages = with pkgs.astal; [
        apps
        battery
        bluetooth
        mpris
        pkgs.networkmanager # this is dumb; should be included by network
        network
        wireplumber

      ];
    in
    {
      environment.systemPackages = with pkgs; [
        (ags.override { inherit extraPackages; })
        brightnessctl
      ];
    };
}
