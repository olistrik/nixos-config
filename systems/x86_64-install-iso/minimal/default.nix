{ pkgs, lib, ... }: 
with lib;
with lib.olistrik;
let
 ssh-key = builtins.getEnv "SSH_AUTH_KEY"; 
in 
{
  networking.hostName = mkForce "nixos-installer";

  olistrik.programs = {
    neovim = enabled;
    zsh = enabled;
  };


  environment.systemPackages = with pkgs; [ 
    git 
  ];

  services = {
    tailscale.enable = true;
    openssh.settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  # use the latest Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Needed for https://github.com/NixOS/nixpkgs/issues/58959
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

}
