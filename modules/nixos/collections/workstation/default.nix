{ lib, config, pkgs, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.collections.workstation;
in
{
  options.olistrik.collections.workstation = basicOptions "workstation configuration and programs";

  config = mkIf cfg.enable {
    # programs that don't need "much" configuration.
    environment.systemPackages = with pkgs; [
      # Git helpers
      olistrik.git-graph
      olistrik.git-igitt

      pavucontrol
    ];

    # TODO: This needs some _serious_ cleanup. like seriously wtf was 23yo me doing.

    # add fonts for polybar and Alacritty.
    fonts.packages = with pkgs; [
      hermit
      (nerdfonts.override { fonts = [ "Hermit" "JetBrainsMono" ]; })
    ];

    # configure alacritty
    olistrik.programs.alacritty = {
      enable = true;
      settings = {
        colors = config.olistrik.system.theme.theme // {
          draw_bold_text_with_bright_colors = true;
        };
        font = {
          normal.family = "JetBrainsMono NerdFont";
        };
        window.opacity = 0.95;
      };
    };

    sound.enable = true;

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      wireplumber.extraConfig = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
        };
      };
    };
  };
}
