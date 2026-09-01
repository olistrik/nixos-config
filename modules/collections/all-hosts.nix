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
        # zsh
        zoxide
        # tmux # broken
        direnv
        nh
      ];

      nixpkgs.config.allowUnfree = true;

      nix.settings = {
        substituters = [
          "https://cache.olii.nl"
          "https://cache.nixos.org"
        ];
        trusted-public-keys = [
          "cache.olii.nl-1:/eobpj1e29xJJ4r2ixYFR4E0t0zNDqu2g9/3ryaRa60="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];

        connect-timeout = 3;
        download-attempts = 1;
        stalled-download-timeout = 15;
        fallback = true;
      };

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

      # TODO: extract to its own module with managed secrets.
      services.tailscale = {
        enable = true;
        useRoutingFeatures = lib.mkDefault "client";
      };

      programs.appimage.binfmt = true;

      users.defaultUserShell = my.pkgs.wrapped.zsh;
      environment.shellAliases = {
        nxs = "nix-search";
      };

      # Public keys come from the shared identity registry.
      # Hestia's automated configuration verifier consumes its store path too.
      environment.etc."git/allowed_signers".text = ''
        strik@olii.nl namespaces="git" ${my.pubkey.yubikey.personal.ssh}
        strik@olii.nl namespaces="git" ${my.pubkey.kvasir.oli.ssh}
        strik@olii.nl namespaces="git" ${my.pubkey.thoth.oli.ssh}
      '';

      environment.etc."gitconfig".text = ''
        [gpg]
          format = ssh
        [gpg "ssh"]
          allowedSignersFile = /etc/git/allowed_signers
      '';

      environment.systemPackages = with pkgs; [
        # Version Control
        npins

        # Fetchers
        git
        wget
        curl
        sshfs

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
        my.pkgs.wrapped.zellij

        # nix-utilities
        nix-search
        my.pkgs.nix-fast-build

        # to wake things
        wakeonlan

        # maintainance tools
        # gen-package-lock # TODO: this is custom.
      ];
    };
}
