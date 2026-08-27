{
  wrappers.config.zsh =
    {
      my,
      config,
      pkgs,
      lib,
      wlib,
      ...
    }:
    {
      imports = [ my.modules.wrappers.programs.zsh ];
      config = {
        zshrc.content = ''
          #################################
          ## Magic Shit

          setopt correct                   # Auto correct mistakes
          setopt extendedglob              # Extended globbing. Allows using regular expressions with *
          setopt nocaseglob                # Case insensitive globbing
          # setopt rcexpandparam             # Array expension with parameters
          # setopt nocheckjobs               # Don't warn about running processes when exiting
          setopt numericglobsort           # Sort filenames numerically when it makes sense
          setopt nobeep                    # No beep
          setopt nointeractivecomments     # Allow # in commands without escaping
          setopt appendhistory             # Immediately append history instead of overwriting
          setopt histignorealldups         # If a new command is a duplicate, remove the older one
          setopt autocd                    # if only directory path is entered, cd there.

          #################################
          ## Enable Ctrl + S and Ctrl + Q

          stty start undef
          stty stop undef
          setopt noflowcontrol

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

          ################################
          ## Direnv

          if command -v direnv &>/dev/null; then
            eval "$(direnv hook zsh)"
          fi

          # TODO: only if it exists.
          source $HOME/.zshrc
        '';

        enableCompletion = true;
        syntaxHighlighting.enable = true;
        autoSuggestions.enable = true;

        runtimePkgs = [ pkgs.direnv ];

        skipGlobalRC = true;

        promptInit = lib.mkDefault ''
          eval "$(${lib.getExe pkgs.starship} init zsh)"
        '';
      };
    };

  wrappers.programs.zsh =
    {
      config,
      pkgs,
      lib,
      wlib,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.zsh ];

      options = with lib.types; {
        promptInit = lib.mkOption {
          description = "Zsh prompt initialization code.";
          default = "";
          type = str;
        };

        enableCompletion = lib.mkOption {
          description = "Enable the completion system (compinit, bashcompinit).";
          default = true;
          type = bool;
        };

        syntaxHighlighting = {
          enable = lib.mkOption {
            description = "Enable zsh-syntax-highlighting.";
            default = false;
            type = bool;
          };
        };

        autoSuggestions = {
          enable = lib.mkOption {
            description = "Enable zsh-autosuggestions.";
            default = false;
            type = bool;
          };
        };

        history = {
          file = lib.mkOption {
            description = "History file path.";
            default = "$HOME/.zsh_history";
            type = str;
          };
          size = lib.mkOption {
            description = "Maximum number of history entries kept in memory.";
            default = 10000;
            type = ints.positive;
          };
          save = lib.mkOption {
            description = "Maximum number of history entries saved to file.";
            default = 10000;
            type = ints.positive;
          };
        };
      };

      config = {
        zshrc.content =
          config.promptInit
          + lib.optionalString config.enableCompletion ''
            ################################
            ## Completion system

            autoload -Uz compinit bashcompinit
            compinit -d $HOME/.zcompdump
            bashcompinit
          ''
          + lib.optionalString (config.history.file != "") ''
            ################################
            ## History

            HISTFILE="${config.history.file}"
            HISTSIZE="${toString config.history.size}"
            SAVEHIST="${toString config.history.save}"
          ''
          + lib.optionalString config.syntaxHighlighting.enable ''
            ################################
            ## Syntax highlighting

            source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
          ''
          + lib.optionalString config.autoSuggestions.enable ''
            ################################
            ## Autosuggestions

            source "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
          '';

        runtimePkgs =
          [ ]
          ++ lib.optional config.syntaxHighlighting.enable pkgs.zsh-syntax-highlighting
          ++ lib.optional config.autoSuggestions.enable pkgs.zsh-autosuggestions;
      };
    };
}
