{ pkgs, ... }: {
  imports = [ ./audio.nix ./themer.nix ./users.nix ./programs/docker.nix ];
  # programs that don't need "much" configuration.
  environment.systemPackages = with pkgs; [
    # Git helpers
    olistrik.git-graph
    olistrik.git-igitt

    # Communications
    signal-desktop

    # USB utils
    ventoy-bin

    # Unpackers
    unrar
  ];
}
