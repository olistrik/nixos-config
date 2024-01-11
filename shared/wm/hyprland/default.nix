{ config, lib, pkgs, ... }: 
	let themer = config.system.themer;
in {
	environment.systemPackages = with pkgs; [
		hyprpaper
		swaylock
	];

	programs.hyprland.enable = true;

	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
	};
}
