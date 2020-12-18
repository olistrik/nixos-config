{
  description = "Nix is love. Nix is life.";

  inputs = {
    secrets-dir = {
      url = "/mnt/etc/nixos/secrets";
      flake = false;
    };
  };

  outputs = {self, nixpkgs, secrets-dir}:
    let
      secrets = import secrets-dir;
    in
    {
      nixosConfigurations = {
      	nixogen = nixpkgs.lib.nixosSystem {
		  system = "x86_64-linux";
		  specialArgs = {
		    inherit secrets;
		  };
		  modules = [
		    ./hosts/nixogen/configuration.nix
		  ];
	};
      };
    };
}
