{
  # TODO: Pretty much all of this should be somewhere else.
  nixos.hosts.all =
    {
      my,
      lib,
      pkgs,
      ...
    }:
    {

      imports = with my.modules.nixos.programs; [
        neovim
        zsh
        zoxide
        # tmux # broken
        direnv
        nh
      ];

      nixpkgs.config.allowUnfree = true;

      # olistrik = {
      #   user = enabled;
      #   programs = {
      #     neovim = enabled;
      #     zsh = enabled;
      #     zoxide = enabled;
      #     tmux = enabled;
      #     btop = enabled;
      #   };
      #   tools = {
      #     direnv = enabled;
      #   };
      # };

      boot.supportedFilesystems = [ "ntfs" ];

      # TODO: What is this one? is it better?
      services.gnome.gcr-ssh-agent.enable = false;

      programs.ssh = {
        startAgent = true;
        enableAskPassword = true;
        askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
        extraConfig = ''
          AddKeysToAgent yes

          Host gitlab.com
            UpdateHostKeys no
        '';
      };

      # Disable the sudoers lecture. I've read it.
      security.sudo.extraConfig = ''
        Defaults lecture = never
      '';

      # TODO: extract to own module with nixwarden secrets.
      services.tailscale = {
        enable = true;
        useRoutingFeatures = lib.mkDefault "client";
      };

      programs.appimage.binfmt = true;

      environment.shellAliases = {
        nxs = "nix-search";
      };

      environment.systemPackages = with pkgs; [
        # Version Control
        npins

        # Fetchers
        git
        wget
        curl

        # Monitoring
        htop
        ncdu

        # Packaging
        zip
        unzip
        unrar
        cachix

        # misc
        killall
        tree
        parallel
        ripgrep
        tmux
        mosh

        # nix-utilities
        nix-search

        # to wake things
        wakeonlan

        # maintainance tools
        # gen-package-lock # TODO: this is custom.
      ];
    };
}
