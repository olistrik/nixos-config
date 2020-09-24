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

    # Debuggers
    gdb
    valgrind

    # Packaging
    binutils
  ];

  # To manage direnv
  services.lorri.enable = true;

}

