{
  modules.optional = {
    docker =
      { lib, ... }:
      let
        inherit (lib) mkEnableOption;
      in
      {
        options = {
          foo = mkEnableOption "bar";
        };

        config = {
          virtualisation.docker = {
            enable = true;
          };
        };
      };
  };
}
