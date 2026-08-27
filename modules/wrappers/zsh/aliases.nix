{
  wrappers.config.zsh = {
    config = {
      zshrc.content = ''
        # expand xargs to match other aliases
        alias xargs="xargs "

        if (( $+commands[systemctl] )); then
          alias zzz="systemctl suspend"
        fi

        if (( $+commands[zathura] )); then
          alias zura="zathura --fork"
        fi

        if (( $+commands[sioyek] )); then
          alias soy="nohup sioyek $@ > /dev/null 2>&1"
        fi

        if (( $+commands[docker-compose] )); then
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
        fi

        #################################
        ## Git specials

        if (( $+commands[git-igitt] )); then
          alias igg="git-igitt"
        fi

        if (( $+commands[git] )); then
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
        fi
      '';
    };
  };
}
