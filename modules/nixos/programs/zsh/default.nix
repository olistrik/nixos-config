{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.programs.zsh;
in
{
  options.olistrik.programs.zsh = with types; {
    enable = mkEnableOption "zsh";
    extraConfig = mkOpt lines "" "Extra configuration to be added to zshrc";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ thefuck fzf starship ];

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

        upfind () {
          ((ls -d $1 2> /dev/null) || ([ "$(realpath $(dirname $1))" == "/" ] || upfind ../$1;)) | xargs realpath 2> /dev/null
        }

        fd() {
          CMD="${pkgs.fd}/bin/fd --strip-cwd-prefix -uu --hidden --follow --exclude .git" 
          if FILE=$(upfind .vimignore); then
            CMD="$CMD --ignore-file=$FILE"
          fi
          eval $CMD $@
        }

        _fzf_compgen_dir() {
          fd -L "$1"
        }

        _fzf_compgen_path() {
          fd --type d -L "$1"
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

        # expand xargs to match other aliases
        alias xargs="xargs "

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

        git-chain-from() {
          if [ $# -ne 1 ]; then
            echo "git-chain-from <source>"
            return 1
          fi
          branches=$(git rev-list --first-parent --ancestry-path --format='%D' $1..HEAD \
            | grep -v commit \
            | sed -E "s;HEAD -> ;;g" \
            | sed -E "s;, ;\n;g" \
            | grep -v "^origin/")

          if [ -z "$branches" ]; then
            return 1
          fi
          echo "$branches"
        }

        #################################
        ## Git specials

        alias igg="git-igitt"

        alias gsw="git switch"
        alias gaa="git add -A"
        alias gci="git add -i && git commit"
        alias gcs="git commit"
        alias gcm="git commit -m"
        alias gcam="git commit --amend --no-edit"
        alias grc="git rebase --continue"
        alias gra="git rebase --abort"
        alias gri="git rebase -i"
        alias gp="git push"
        alias gpf="git push --force-with-lease"

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
      '' + cfg.extraConfig;

      promptInit = ''
        eval "$(starship init zsh)"
      '';
    };
  };
} 
