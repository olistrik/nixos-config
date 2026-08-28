{
  nixos.system.agenix =
    {
      config,
      lib,
      my,
      pkgs,
      ...
    }:
    {
      imports = [
        (my.sources.agenix + "/modules/age.nix")
      ];

      options.age.secrets = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule (
            { config, ... }: {
              options.file = lib.mkOption {
                type = lib.types.path;
                default = ../../secrets + "/${config._module.args.name}.age";
              };
            }
          )
        );
      };

      config.environment.systemPackages = [
        pkgs.age
        (pkgs.callPackage (my.sources.agenix + "/pkgs/agenix.nix") { })
      ];
    };
}
