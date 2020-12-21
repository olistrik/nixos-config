
{config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    thefuck
    fzf
    starship
    direnv
    zplug
  ];

  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    interactiveShellInit = import ../../dots/zshrc { inherit pkgs; };
    promptInit = ''
      eval "$(starship init zsh)"
    '';
  };

}
