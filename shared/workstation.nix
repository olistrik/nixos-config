{ pkgs, ... }: {
  imports = [
    ./audio.nix
    ./themer.nix
    ./users.nix
    ./programs/docker.nix
    ./programs/alacritty.nix
  ];

  # programs that don't need "much" configuration.
  environment.systemPackages = with pkgs; [
    # Git helpers
    olistrik.git-graph
    olistrik.git-igitt
  ];
}
