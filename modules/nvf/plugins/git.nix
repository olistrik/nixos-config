{
  nvf.config.git =
    {
      pkgs,
      config,
      lib,
      options,
      ...
    }:
    {
      config.vim = {
        git.gitsigns = {
          enable = true;

          setupOpts = {
            current_line_blame = true;
          };
        };
      };
    };
}
