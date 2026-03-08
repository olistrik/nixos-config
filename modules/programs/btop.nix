{
  nixos.programs.btop =
    { pkgs, ... }:
    {
      # TODO: check cuda and rocm support.
      environment.systemPackages = [ pkgs.btop ];
    };
}
