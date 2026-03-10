{
  nixos.programs.neovim =
    { self, ... }:
    {
      environment.variables.EDITOR = "nvim";

      # TODO: load the wrapper.
      environment.systemPackages = with self.pkgs.wrapped; [ nvim-full ];
    };
}
