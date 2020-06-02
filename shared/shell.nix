
{config, pkgs, ...}:

{

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  programs.zsh.ohMyZsh = {
    enable = true;

    plugins = ["git" "sudo"];
  };

}
