{
  nixos.programs.nh = {
    programs.nh = {
      enable = true;
    };
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
