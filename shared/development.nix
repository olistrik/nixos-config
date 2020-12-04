{config, lib, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    # Compilers
    gcc10

    # Rust
    cargo
    carnix

    # Compile Managers
    gnumake
    bear

    # Environment Managers
    direnv
    nix-direnv

    # Debuggers
    gdb
    valgrind

    # Packaging
    binutils


    # Docker
    docker-compose
  ];

  # enable docker
  virtualisation.docker.enable = true;
  users.users.kranex.extraGroups = [ "docker" ];

  # To manage direnv
  # services.lorri.enable = true;

  # nix options for derivations to persist garbage collection
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

}

