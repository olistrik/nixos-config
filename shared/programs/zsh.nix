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
    interactiveShellInit = ''
    #################################
    ## Hook direnv
    eval "$(direnv hook zsh)"

    #################################
    ## source and install zplug

    source ${pkgs.zplug}/init.zsh

    zplug "agkozak/zsh-z"

    if ! zplug check; then
      zplug install
    fi
    zplug load

    #################################
    ## fix nix

    function _nix() {
      local ifs_bk="$IFS"
      local input=("''${(Q)words[@]}")
      IFS=$'\n'
      local res=($(NIX_GET_COMPLETIONS=$((CURRENT - 1)) "$input[@]"))
      IFS="$ifs_bk"
      local tpe="$res[1]"
      local suggestions=(''${res:1})
      if [[ "$tpe" == filenames ]]; then
        compadd -fa suggestions
      else
        compadd -a suggestions
      fi
    }

    compdef _nix nix

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
      ## Enable vi mode
      bindkey -v

      #################################
      ## Aliases
      alias zzz="systemctl suspend"
      alias zura="zathura --fork"
      alias dcu="docker-compose up -d"
      alias dcd="docker-compose down"
      alias dcb="docker-compose build --parallel"

    '';
    promptInit = ''
      eval "$(starship init zsh)"
    '';
  };

}
