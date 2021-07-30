{config, pkgs, ...}:

{
  nvironment.systemPackages = with pkgs; [
    pavucontrol
  ];

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    extraConfig = ''
    '';
  };
}
