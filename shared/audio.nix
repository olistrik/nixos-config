{config, pkgs, ...}:

{
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  #hardware.pulseaudio = {
  #  enable = true;
  #  support32Bit = true;
  #};
}
