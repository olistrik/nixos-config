{ config, lib, pkgs, ... }: 
	let themer = config.system.themer;
in {
	programs.hyprland.enable = true;

	environment.systemPackages = with pkgs; [
		hyprpaper
		swaylock
	];
}
