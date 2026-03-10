{
  nixos = rec {
    system.locale =
      { lib, ... }:

      let
        inherit (lib) mkDefault;
      in
      {
        time.timeZone = mkDefault "Europe/Amsterdam";
        i18n = {
          defaultLocale = mkDefault "en_GB.UTF-8";
          extraLocaleSettings = builtins.listToAttrs (
            map
              (name: {
                inherit name;
                value = mkDefault "nl_NL.UTF-8";
              })
              [
                "LC_ADDRESS"
                "LC_IDENTIFICATION"
                "LC_MEASUREMENT"
                "LC_MONETARY"
                "LC_NAME"
                "LC_NUMERIC"
                "LC_PAPER"
                "LC_TELEPHONE"
                "LC_TIME"
              ]
          );
        };
      };

    hosts.all.imports = [ system.locale ];
  };
}
