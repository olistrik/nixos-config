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
      config = {
        zshrc.content =
          let
            fd = lib.getExe pkgs.fd;
            # fzf-share cannot be found with getExe (it's a dir).
            fzf-share = "${pkgs.fzf}/bin/fzf-share";
          in
          ''
            #################################
            ## Enable fzf searching.

            upfind () {
              ((ls -d $1 2> /dev/null) || ([ "$(realpath $(dirname $1))" == "/" ] || upfind ../$1;)) | xargs realpath 2> /dev/null
            }

            _fd() {
              CMD="${fd} --strip-cwd-prefix -uu --hidden --follow --exclude .git"
              if FILE=$(upfind .vimignore); then
                CMD="$CMD --ignore-file=$FILE"
              fi
              eval $CMD $@
            }

            _fzf_compgen_dir() {
              _fd -L "$1"
            }

            _fzf_compgen_path() {
              _fd --type d -L "$1"
            }

            source "$(${fzf-share})/key-bindings.zsh"
            source "$(${fzf-share})/completion.zsh"
          '';
      };
    };
}
