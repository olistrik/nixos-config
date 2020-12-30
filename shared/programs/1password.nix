
{config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    _1password
  ];
}
