{
  # TODO: Probably wrap this?
  nixos.programs.direnv = {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
