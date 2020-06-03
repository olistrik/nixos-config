
{config, pkgs, ...}:

{

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ 
    alacritty	# prefered terminal
    xterm	# nice to have a backup
  ];


}
