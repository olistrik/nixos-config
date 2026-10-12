{
  nixos.programs.walker =
    { pkgs, ... }:
    {
      # nixpkgs' elephant builds every provider and points ELEPHANT_PROVIDER_DIR
      # at them, so no per-provider wiring is needed.
      services.elephant.enable = true;

      environment.systemPackages = [ pkgs.walker ];

      # elephant searches every XDG config dir for <provider>.toml.
      environment.etc."xdg/elephant/desktopapplications.toml".text = ''
        # rank by launch history even before anything is typed
        history_when_empty = true
      '';

      systemd.user.services = {
        elephant = {
          unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
          # Launched apps and runner commands resolve through this PATH.
          path = [ "/run/current-system/sw" ];
        };

        # Keeping walker resident as a gapplication service makes the launcher
        # appear instantly; `walker` then just talks to the running instance.
        walker = {
          description = "Walker - Application Runner";
          after = [
            "graphical-session.target"
            "elephant.service"
          ];
          requires = [ "elephant.service" ];
          partOf = [ "graphical-session.target" ];
          wantedBy = [ "graphical-session.target" ];
          unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
          path = [ "/run/current-system/sw" ];
          serviceConfig = {
            ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
            Restart = "on-failure";
          };
        };
      };
    };
}
