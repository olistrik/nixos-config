{
  wrappers.config.zsh =
    { pkgs, lib, ... }:
    {
      config = {
        zshrc.content =
          let
            pr = lib.getExe pkgs.pay-respects;
          in
          ''
            #################################
            ## Enable pay-respects on ESC-ESC

            _pr_esc_esc() {
              eval $(_PR_LAST_COMMAND="$(fc -ln -1)" _PR_ALIAS="`alias`" _PR_SHELL="zsh" ${pr})
            }
            zle -N _pr_esc_esc
            bindkey -M emacs '\e\e' _pr_esc_esc
            bindkey -M vicmd '\e\e' _pr_esc_esc
            bindkey -M viins '\e\e' _pr_esc_esc
          '';
      };
    };
}
