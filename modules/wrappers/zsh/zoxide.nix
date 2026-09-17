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

        # The functions `zoxide init zsh` generates (`z`, `zi`) call the bare
        # `zoxide` command, not an embedded absolute path, so it needs to be
        # on PATH at runtime, not just available to generate the init script.
        runtimePkgs = [ pkgs.zoxide ];
      };
    };
}
