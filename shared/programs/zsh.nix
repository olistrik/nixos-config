
{config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    thefuck
    fzf
    starship
    direnv
  ];

  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    interactiveShellInit = ''
      #################################
      ## Magic Shit

      setopt correct                   # Auto correct mistakes
      setopt extendedglob              # Extended globbing. Allows using regular expressions with *
      setopt nocaseglob                # Case insensitive globbing
      # setopt rcexpandparam             # Array expension with parameters
      # setopt nocheckjobs               # Don't warn about running processes when exiting
      setopt numericglobsort           # Sort filenames numerically when it makes sense
      setopt nobeep                    # No beep
      setopt appendhistory             # Immediately append history instead of overwriting
      setopt histignorealldups         # If a new command is a duplicate, remove the older one
      setopt autocd                    # if only directory path is entered, cd there.

      #################################
      ## Enable Ctrl + S and Ctrl + Q

      stty start undef
      stty stop undef
      setopt noflowcontrol

      #################################
      ## Enable fzf searching.
      if [ -n "''${commands[fzf-share]}" ]; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      fi

      #################################
      ## Enable thefuck on ESC-ESC
      #Register alias
      eval "$(thefuck --alias)"

      fuck-command-line() {
        local FUCK="$(THEFUCK_REQUIRE_CONFIRMATION=0 thefuck $(fc -ln -1 | tail -n 1) 2> /dev/null)"
        [[ -z $FUCK ]] && echo -n -e "\a" && return
        BUFFER=$FUCK
        zle end-of-line
      }
      zle -N fuck-command-line
      # Defined shortcut keys: [Esc] [Esc]
      bindkey -M emacs '\e\e' fuck-command-line
      bindkey -M vicmd '\e\e' fuck-command-line
      bindkey -M viins '\e\e' fuck-command-line


      #################################
      ## Hook direnv
      eval "$(direnv hook zsh)"

      #################################
      ## Enable vi mode
      bindkey -v

      #################################
      ## Aliases
      alias zzz="systemctl suspend"
      alias zura="zathura --fork"

    '';
    promptInit = ''
      eval "$(starship init zsh)"
    '';
  };

}
