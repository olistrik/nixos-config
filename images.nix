args@{
  my ? import ./. args,
  ...
}:
let
  pkgs = import my.sources.nixpkgs { };
  nixosSystem = import "${pkgs.path}/nixos/lib/eval-config.nix";

  diskoVersion = (import (my.sources.disko + "/version.nix")).version;
  disko = pkgs.callPackage (my.sources.disko + "/package.nix") {
    inherit diskoVersion;
  };

  installerSystem = nixosSystem {
    specialArgs = { inherit my; };
    modules = [
      "${my.sources.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      "${my.sources.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
      {
        users.users.root.openssh.authorizedKeys.keys = with my.pubkey; [
          thoth.oli.ssh
          yubikey.personal.ssh
        ];

        environment.systemPackages = [
          pkgs.git
          disko
          my.pkgs.wrapped.nvim.minimal
        ];

        isoImage.squashfsCompression = "zstd";
      }
    ];
  };
in
{
  installer = installerSystem.config.system.build.isoImage;
}
