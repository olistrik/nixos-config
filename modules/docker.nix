{
  lib,
  self,
  inputs,
  ...
}:
{
  flake.debug = lib.evalModules {
    specialArgs = {
      inherit lib self;
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    };

    modules = with self.modules.nixos; [
      base
      double-docker
    ];
  };

  flake.modules.nixos = rec {
    base =
      { lib, pkgs, ... }:
      {
        options.virtualization.docker = {
          package = lib.mkPackageOption pkgs "docker" { };
        };
        options.virtualization.zsh = {
          package = lib.mkPackageOption pkgs "zsh" { };
        };
      };

    docker =
      { lib, pkgs, ... }:
      {
        key = "nixos.docker";
        virtualization.docker.package = pkgs.zsh;
      };
    double-docker = {
      key = "nixos.double-docker";
      imports = [
        docker
        docker
      ];
    };
  };
}
