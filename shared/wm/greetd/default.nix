{ config, ... }: {
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${config.programs.hyprland.package}/bin/Hyprland";
        user = "oli";
      };
      default_session = initial_session;
    };
  };
}
