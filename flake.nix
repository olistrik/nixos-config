{
  description = "Nix is love. Nix is life.";

  inputs = {
    unstable = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
  };

  outputs = {self, nixpkgs, unstable}:
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
            inherit pkgs pkgs-unstable;
          };

          modules = [ ./hosts/nixbidium/configuration.nix ];
        in

        nixpkgs.lib.nixosSystem { inherit system modules specialArgs; };
    };
}
