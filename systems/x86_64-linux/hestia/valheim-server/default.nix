{ pkgs, ... }: {
  olistrik.services.valheim-server = {
    enable = true;
    extraOptions = {
      bepinexMods = [
        # This does NOT fetch mod dependencies.  
        # You need to add those manually, if there are any (besides BepInEx).
        (pkgs.fetchValheimThunderstoreMod {
          owner = "blacks7ar";
          name = "WieldEquipmentWhileSwimming";
          version = "1.0.8";
          hash = "sha256-pRqkD5Yonw5OGeGMJFoRax5gxRhdUSa1+2FT0znBleQ=";
        })
        (pkgs.fetchValheimThunderstoreMod {
          owner = "Azumatt";
          name = "AzuMiscPatches";
          version = "1.2.2";
          hash = "sha256-DnDVpfNZVO87Xv6bYxFHjTmwwEHu9wjImiRSgGXlQZA=";
        })
        (pkgs.fetchValheimThunderstoreMod {
          owner = "Azumatt";
          name = "AzuExtendedPlayerInventory";
          version = "1.3.12";
          hash = "sha256-AZvDYlo+VM5NXBgqiKS5MHANMLEmZqqQxXL2stI/F2c=";
        })
        (pkgs.fetchValheimThunderstoreMod {
          owner = "Azumatt";
          name = "AzuCraftyBoxes";
          version = "1.2.9";
          hash = "sha256-d7T+M/Zij7n2lDUEv7pJZyIcQWfbxToEsvnfjMDbjcs=";
        })
        # ...
      ];
      bepinexConfigs = [
        # ./Azumatt_and_ValheimPlusDevs.PerfectPlacement.cfg
        ./blacks7ar.WieldEquipmentWhileSwimming.cfg
        ./Azumatt.AzuMiscPatches.cfg
        ./Azumatt.AzuExtendedPlayerInventory.cfg
        ./Azumatt.AzuCraftyBoxes.cfg
      ];
    };
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
