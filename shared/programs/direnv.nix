{ config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    direnv
    nix-direnv
  ];

  # Configure direnv, also requires `eval ${direnv hook zsh)` in zsh.
  # TODO move direnv to it's own module and make it set that hook somehow.
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  nixpkgs.overlays = [
    (self: super: {
      nix-direnv = super.nix-direnv.override { 
        enableFlakes = true;
      };
    })
  ];
}
