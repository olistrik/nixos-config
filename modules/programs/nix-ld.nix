{
  nixos.programs.nix-ld = {
    programs.nix-ld.enable = true;
    #   nix-ld.libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs;
  };
}
