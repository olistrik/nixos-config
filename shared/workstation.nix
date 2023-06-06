{ pkgs, ... }: {
  imports = [ ./audio.nix ./themer.nix ./users.nix ./programs/docker.nix ];
  # programs that don't need "much" configuration.
  environment.systemPackages = with pkgs; [
    # Git helpers
    kranex.git-graph
    kranex.git-igitt

    # Communications
    signal-desktop

    # USB utils
    ventoy-bin

    # Unpackers
    unrar
  ];
}
