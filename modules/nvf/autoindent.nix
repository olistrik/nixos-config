{
  nvf.config.autoindent =
    { pkgs, ... }:
    {
      # TODO: options.

      config.vim = {
        extraPlugins = with pkgs.vimPlugins; {
          guess-indent = {
            package = guess-indent-nvim;
            setup = /* lua */ ''
              require("guess-indent").setup({})
            '';
          };
        };
      };
    };
}
