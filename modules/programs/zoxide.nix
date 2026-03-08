{
  # TODO: probably wrap? It'll be part of the zsh wrapper at least.
  nixos.programs.zoxide = {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
