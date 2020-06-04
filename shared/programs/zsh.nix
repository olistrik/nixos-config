
{config, pkgs, ...}:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  environment.systemPackages = with pkgs; [
    thefuck
    fzf
    starship
  ];
  
  fonts.fonts = with pkgs; [
    (unstable.nerdfonts.override { fonts = ["Hermit" "JetBrainsMono"]; })
  ];

  users.defaultUserShell = pkgs.zsh;
  
  programs.alacritty.font.normal.family = "JetBrainsMono Nerd Font";
  
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    interactiveShellInit = ''
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
    '';
    promptInit = ''
      eval "$(starship init zsh)"
    '';
  };

}
