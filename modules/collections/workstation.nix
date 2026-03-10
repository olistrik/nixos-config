{
  nixos.collections.workstation =
    {
      self,
      pkgs,
      config,
      ...
    }:
    {
      imports = with self.modules.nixos; [
        system.theme
        # programs.alacritty
      ];

      # programs that don't need "much" configuration.
      environment.systemPackages =
        with pkgs;
        with self.pkgs;
        [
          # Git helpers
          git-igitt
          pavucontrol

          wrapped.alacritty
        ];

      programs.localsend.enable = true;

      # TODO: This needs some _serious_ cleanup. like seriously wtf was 23yo me doing.

      # add fonts for polybar and Alacritty.
      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];

      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;

        # wireplumber.extraConfig."10-bluez" = {
        #   "monitor.bluez.properties" = {
        #     "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "bap_sink" "bap_source" "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
        #     "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" "aptx" "aptx_hd" "ldac" "faststream" ];
        #     "bluez5.enable-sbc-xq" = true;
        #     "bluez5.enable-aptx" = true;
        #     "bluez5.enable-ldac" = true;
        #     "bluez5.enable-faststream" = true;
        #     "bluez5.enable-hw-volume" = true;
        #     "bluez5.hfphsp-backend" = "native";
        #   };
        # };
      };
    };
}
