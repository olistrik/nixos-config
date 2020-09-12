{config, lib, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    # Compilers
    gcc10

    # Compile Managers
    gnumake
    bear

    # Environment Managers
    direnv
  ];

  # To manage direnv
  services.lorri.enable = true;

}

