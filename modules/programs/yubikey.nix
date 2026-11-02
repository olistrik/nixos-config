{
  nixos.programs.yubikey =
    { pkgs, ... }:
    {
      # pcscd is the smartcard daemon; the YubiKey's OATH, PIV and OpenPGP
      # applications are all reached through it (CCID interface).
      services.pcscd.enable = true;

      # udev rules so an active local session can talk to the key (FIDO/OTP
      # HID interfaces) without root.
      services.udev.packages = [ pkgs.yubikey-personalization ];

      environment.systemPackages = with pkgs; [
        # `ykman` CLI: manage applications and OATH accounts
        # (e.g. `ykman oath accounts add|list|code`).
        yubikey-manager
      ];
    };
}
