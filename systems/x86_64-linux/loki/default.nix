# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ lib, pkgs, ... }:
with lib; with olistrik;
{
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
    cudaVersion = "12";
  };

  wsl = {
    enable = true;
    defaultUser = "oli";
    useWindowsDriver = true;
    docker-desktop.enable = true;
  };

  olistrik = {
    collections = {
      server = enabled;
    };
  };

  programs.mosh.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

  environment.sessionVariables = {
    CUDA_PATH = "${pkgs.cudatoolkit}";
    EXTRA_LDFLAGS = "-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib";
    EXTRA_CCFLAGS = "-I/usr/include";
    LD_LIBRARY_PATH = [
      "/usr/lib/wsl/lib"
      "${pkgs.linuxPackages.nvidia_x11}/lib"
      "${pkgs.ncurses5}/lib"
    ];

    MESA_D3D12_DEFAULT_ADAPTER_NAME = "Nvidia";
  };

  hardware.nvidia-container-toolkit = {
    enable = true;
    mount-nvidia-executables = false;
  };

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    daemon.settings.features.cdi = true;
    daemon.settings.cdi-spec-dirs = [ "/etc/cdi" ];
  };

  systemd.services = {
    nvidia-cdi-generator = {
      description = "Generate nvidia cdi";
      wantedBy = [ "docker.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.nvidia-docker}/bin/nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml --nvidia-ctk-path=${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk";
      };
    };
  };

  networking.interfaces = {
    eth0.mtu = 1500;
  };

  # I probably want a global toggle for this, it will follow
  # config.cudaSupport, but that feels a little heavy handed.
  olistrik.programs.btop.cudaSupport = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}


