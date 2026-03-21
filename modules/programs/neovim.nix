{
  nixos.programs.neovim =
    { my, ... }:
    {
      environment.variables.EDITOR = "nvim";

      # TODO: load the wrapper.
      environment.systemPackages = with my.pkgs.wrapped; [ nvim-full ];
    };
}
