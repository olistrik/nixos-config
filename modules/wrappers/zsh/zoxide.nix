{
  wrappers.config.zsh =
    { pkgs, lib, ... }:
    {
      config = {
        zshrc.content =
          let
            zoxide = lib.getExe pkgs.zoxide;
          in
          ''
            eval "$(${zoxide} init zsh)"
          '';
      };
    };
}
