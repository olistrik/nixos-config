{ config, lib, pkgs, programs, ... }: {
	services.greetd = {
		enable = true;
		settings = rec {
			initial_session = {
				command = "${programs.hyprland.package}/bin/Hyprland";
				user = "myuser";
			};
			default_session = initial_session;
		};
	};
}
