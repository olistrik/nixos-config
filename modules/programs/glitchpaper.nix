{
  nixos.programs.glitchpaper =
    {
      my,
      pkgs,
      ...
    }:
    let
      glitchpaper = pkgs.callPackage (my.sources.glitchpaper + "/nix/package.nix") { };
      args = "/home/oli/.lockscreen --logo /home/oli/.lockscreen-logo --logo-color invert";

      # Lock or nothing: there is deliberately no screensaver without a lock.
      glitchlock = pkgs.writeShellApplication {
        name = "glitchlock";
        runtimeInputs = [
          glitchpaper
          pkgs.swaylock-plugin
          # swaylock-plugin runs --command through `sh -c`, and swayidle's
          # service PATH has no sh: without this, idle and lid locks get no
          # background at all.
          pkgs.bash
        ];
        text = ''
          # One glitchpaper for all outputs (--command, not --command-each) keeps
          # the bursts in sync across screens.
          exec swaylock-plugin --command "glitchpaper background ${args}" "$@"
        '';
      };
    in
    {
      environment.systemPackages = [
        glitchpaper
        glitchlock
      ];

      # swaylock-plugin authenticates through its own PAM service.
      security.pam.services.swaylock-plugin = { };

      systemd.user.services.swayidle.path = [ glitchlock ];
    };
}
