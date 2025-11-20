{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;

    identMap = ''
      superuser_map root postgres
      superuser_map postgres postgres
      superuser_map /^(.*)$ \1
    '';

    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method optional_ident_map
      local sameuser  all     peer        map=superuser_map
    '';
  };
}
