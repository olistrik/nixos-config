{ pkgs, lib, inputs, ... }:
with lib;
with lib.olistrik;
{
  networking.hostName = mkForce "nixos-installer";

  olistrik = {
    user = enabled;
    # collections = {
    #   server = enabled;
    # };
    programs = {
      neovim = enabled;
      zsh = enabled;
    };
  };

  environment.systemPackages = with pkgs; [
    git
    inputs.disko.packages.x86_64-linux.default
  ];

  # services = {
  #   tailscale.enable = true;
  # };

  # use the latest Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Needed for https://github.com/NixOS/nixpkgs/issues/58959
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

}
