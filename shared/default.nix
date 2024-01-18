# The default configuration for all systems.
# May need to be further divided in the future to allow for easier control
# of different kinds of systems.

{ pkgs, ... }: {

  imports = [
    # install programs with my configurations
    ./programs/zsh.nix
    ./programs/neovim
    ./programs/direnv.nix
    ./programs/tailscale.nix
  ];

  boot.supportedFilesystems = [ "ntfs" ];

  # Every pc needs this.
  programs = {
    ssh = {
      extraConfig = ''
        Host gitlab.com
          UpdateHostKeys no
      '';
    };
  };

  # programs that don't need "much" configuration.
  environment.systemPackages = with pkgs; [
    # Fetchers
    git
    wget
    curl
    
    # Monitoring
    htop

    # Packaging
    zip
    unzip
    unrar

    # misc
    killall
    neofetch
    tree
    parallel
    ripgrep

    # USB utils
    ventoy-bin
  ];
}
