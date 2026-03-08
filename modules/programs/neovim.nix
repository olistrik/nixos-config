{
  nixos.programs.neovim =
    { pkgs, ... }:
    {
      environment.variables.EDITOR = "nvim";

      # TODO: load the wrapper.
      environment.systemPackages = with pkgs; [ neovim ];
    };
}
