
{config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    thefuck
    fzf
    starship
];

  users.defaultUserShell = pkgs.zsh;
  
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    interactiveShellInit = ''
      if [ -n "''${commands[fzf-share]}" ]; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      fi

    '';
    promptInit = ''
      eval "$(starship init zsh)"
    '';
  };

}
