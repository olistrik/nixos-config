{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ thefuck fzf starship direnv zplug ];

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
                              		export FZF_DEFAULT_COMMAND="fd --strip-cwd-prefix -uu --ignore-file=.vimignore"

                        			  _fzf_compgen_dir() {
                        				command fd -L "$1" \
            							  --strip-cwd-prefix \
            							  --ignore-file .vimignore \
                        				  --exclude .git --exclude .hg --exclude .svn \
            							  -t d 2> /dev/null
                        			  }

      							  _fzf_compgen_path() {
      								echo "$1"
      								command find -L "$1" \
      								  --strip-cwd-prefix \
      								  --ignore-file .vimignore \
      								  --exclude .git --exclude .hg --exclude .svn \
      								  -t d  -t f -t l 2> /dev/null
      							  }

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
                                    ## bindkey -v

                                    #################################
                                    ## Aliases
                                    alias zzz="systemctl suspend"
                                    alias zura="zathura --fork"

                                    alias dc="docker-compose"
                                    alias dcu="docker-compose up -d"
                                    alias dcd="docker-compose down"
                                    alias dcb="docker-compose build --parallel"
                                    alias dcr="docker-compose restart"
                                    alias dce="docker-compose exec"
                                    alias dcl="docker-compose logs -f"

                                    dcp() {
                                      cmd="docker-compose"
                                      for profile in $@; do
                                        cmd="$cmd --profile $profile"
                                      done
                                      cmd="$cmd up -d"

                                      eval $cmd
                                    }

                                    #################################
                                    ## Git specials

                                    grb() {
                                      [[ -z $1 ]] && echo "usage: grb <branch to rebase on>" && return 1
                                      [[ -n $(git status -s) ]] && "please commit changes first" && return 1
                                      git checkout $1
                                      git pull
                                      git checkout -
                                      git rebase $1
                                    }
                                    compdef _git grb=git-rebase

                                    alias gg="git-graph"
                                    alias igg="git-igitt"
                                    alias gsw="git switch"
                                    alias gaa="git add -A"
                                    alias gca="git add -A && git commit"
                                    alias gci="git add -i && git commit"
                                    alias gcs="git commit"
                                    alias gcm="git commit -m"
                                    alias gcam="git commit --amend --no-edit"
                                    alias grc="git rebase --continue"
                                    alias gra="git rebase --abort"
                                    alias git-home="git config user.email oliverstrik@gmail.com && git config user.name Kranex && git config -l | grep user"
                                    alias git-work="git config user.email oliver@klippa.com && git config user.name 'Oliver Strik' && git config -l | grep user"

                                    ################################
                                    ## Fuzzy completion


                                    # 0 -- vanilla completion (abc => abc)
                                    # 1 -- smart case completion (abc => Abc)
                                    # 2 -- word flex completion (abc => A-big-Car)
                                    # 3 -- full flex completion (abc => ABraCadabra)
                                    zstyle ':completion:*' matcher-list "" \
                                      'm:{a-z\-}={A-Z\_}' \
                                      'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
                                      'r:|?=** m:{a-z\-}={A-Z\_}'
    '';

    promptInit = ''
      eval "$(starship init zsh)"
    '';
  };

}
