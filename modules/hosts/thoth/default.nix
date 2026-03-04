# Thoth is my personal laptop as it is used primarily for university work and
# provisioning my other nixos hosts.

{
  self,
  inputs,
  config,
  ...
}:
{
  flake.nixosConfigurations.thoth = inputs.nixpkgs.lib.nixosSystem {
    modules =
      with inputs;
      [
        disko.nixosModules.default
        impermanence.nixosModules.impermanence

        ./_hardware-configuration.nix
        ./_disko-configuration.nix
        ./_persistance-configuration.nix
      ]
      ++ (with config.modules; [
        optional.all
        nixos.thoth
      ]);
  };
}
