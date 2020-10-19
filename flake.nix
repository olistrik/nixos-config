{
  description = "Nix is love. Nix is life.";

  inputs = {
    unstable = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    secrets = {
      url = "/etc/nixos/secrets";
      flake = false;
    };
  };

  outputs = {self, nixpkgs, unstable, secrets}:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      pkgs-unstable = import unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {

      nixosConfigurations.nixbidium =
        let

          system = "x86_64-linux";

          specialArgs = {
            inherit pkgs pkgs-unstable secrets;
          };

          modules = [ ./hosts/nixbidium/configuration.nix ];
        in

        nixpkgs.lib.nixosSystem { inherit system modules specialArgs; };
    };
}
