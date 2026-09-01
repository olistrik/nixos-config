{
  nixos.system.plymouth = {
    boot = {
      # Plymouth supplies the graphical prompt shown while cryptroot is opened.
      plymouth.enable = true;

      # Route systemd's LUKS ask-password request through Plymouth in stage 1.
      initrd.systemd.enable = true;
    };
  };
}
