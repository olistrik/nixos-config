{
  nixos.programs.neovim =
    { my, ... }:
    {
      environment.variables.EDITOR = "nvim";

      # TODO: load the wrapper.
      environment.systemPackages = [ my.pkgs.wrapped.nvim.default ];
    };
}
