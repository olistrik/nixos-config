{
  modules.optional = {
    docker =
      { lib, cfg, ... }:
      let
        inherit (lib) mkEnableOption;
      in
      {
        options = {
          foo = mkEnableOption "foo";
        };

        config = {
          olistrik.modules.docker.foo = true;

          virtualisation.docker = {
            enable = cfg.foo;
          };
        };
      };
  };
}
