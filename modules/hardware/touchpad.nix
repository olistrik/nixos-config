{
  nixos.hardware.touchpad = {
    services.libinput.touchpad.disableWhileTyping = true;
  };
}
