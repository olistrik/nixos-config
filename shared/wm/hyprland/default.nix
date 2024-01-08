{ config, lib, pkgs, ... }: 
	let themer = config.system.themer;
in {
	programs.hyprland.enable = true;
	programs.hyprland.package = pkgs.unstable.hyprland;

	environment.systemPackages = with pkgs; [
		hyprpaper
	];
}
