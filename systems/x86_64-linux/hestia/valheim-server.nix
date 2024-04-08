{ ... }: {
  olistrik.services.valheim-server = {
    enable = true;
    # If you want to use BepInEx mods.
    # bepinexMods = [
    #   # This does NOT fetch mod dependencies.  You need to add those manually,
    #   # if there are any (besides BepInEx).
    #   (pkgs.fetchValheimThunderstoreMod {
    #     owner = "Somebody";
    #     name = "SomeMod";
    #     version = "x.y.z";
    #     hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    #   })
    #   # ...
    # ];
    # bepinexConfigs = [
    #   ./some_mod.cfg
    #   # ...
    # ];
  };
}
