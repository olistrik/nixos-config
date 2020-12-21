# Install and configure neovim + plugins.

{pkgs, ...}:
{
  environment.variables = { EDITOR = "vim"; };
  environment.systemPackages = with pkgs; [
    (neovim.override {
      vimAlias = true;
      configure = {
        packages.myPlugins = with pkgs.unstable.vimPlugins; {
          start = [
            # Language Support
            vim-nix
            vim-pandoc
            vim-pandoc-syntax
            plantuml-syntax
            i3config-vim

            vim-table-mode

            # QOL
            vim-gitgutter
            fzf-vim
            vim-repeat
            auto-pairs
            vim-surround
            nerdtree
            nerdtree-git-plugin

            # IDE
            ale
            YouCompleteMe

            # Themes
            ayu-vim
          ];
          opt = [];
        };
        customRC = builtins.readFile ../../dots/vimrc;
      };
    })];

  }
