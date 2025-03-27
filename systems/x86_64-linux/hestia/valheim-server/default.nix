{ pkgs, ... }: {
  olistrik.services.nixwarden.secrets = {
    "valheim.adminlist.txt" = [{
      location = "/var/lib/valheim/adminlist.txt";
      wantedBy = [ "valheim.service" ];
      userGroup = "valheim:valheim";
    }];
  };

  olistrik.services.valheim-server = {
    enable = true;
    extraOptions = {
      adminListFile = "/var/lib/valheim/adminlist.txt";

      bepinexMods = [
        # This does NOT fetch mod dependencies.  
        # You need to add those manually, if there are any (besides BepInEx).
        # (pkgs.fetchValheimThunderstoreMod {
        #   owner = "blacks7ar";
        #   name = "WieldEquipmentWhileSwimming";
        #   version = "1.1.2";
        #   hash = "sha256-UotiInuJAZsR1sL9aquTBQf7sw5kzG+2fG8QlFl+2Fc=";
        # })
        (pkgs.fetchValheimThunderstoreMod {
          owner = "Azumatt";
          name = "AzuMiscPatches";
          version = "1.2.6";
          hash = "sha256-kl2/dTgViBkEAp75GJEdLFKaJPHI8vEVFOIUCBkoaCA=";
        })
        (pkgs.fetchValheimThunderstoreMod {
          owner = "Azumatt";
          name = "AzuExtendedPlayerInventory";
          version = "1.4.9";
          hash = "sha256-Xd7KdUm3c14iQBST31DAqs+bQF9hwYhUxE66o3lusrA=";
        })
        (pkgs.fetchValheimThunderstoreMod {
          owner = "Azumatt";
          name = "AzuCraftyBoxes";
          version = "1.7.2";
          hash = "sha256-Omzdh6p3xz2HSq0WlbMFzFcgBINwTthMqF7fkgWKweE=";
        })
        # ...
      ];
      bepinexConfigs = [
        # ./Azumatt_and_ValheimPlusDevs.PerfectPlacement.cfg
        # ./blacks7ar.WieldEquipmentWhileSwimming.cfg
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
