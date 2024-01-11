{ config, lib, pkgs, ... }: 
	let themer = config.system.themer;
in {
	environment.systemPackages = with pkgs; [
		hyprpaper
		swaylock
	];

	environment.sessionVariables.NIXOS_OZONE_WL = "1";

	programs.hyprland.enable = true;

	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
	};

	xdg.portal = {
		enable = true;
		extraPortals = with pkgs; [
			xdg-desktop-portal-wlr
			xdg-desktop-portal-gtk
		];
		xdgOpenUsePortal = true;
	};
}
