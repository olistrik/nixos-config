{config, pkgs, ...}:

{

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    # Web get tools.
    wget # for wgeting things.
    git

  ];

}
