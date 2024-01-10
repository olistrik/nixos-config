{ config, lib, pkgs, ... }: {
  imports = [ ./programs/jetbrains.nix ];

  networking.extraHosts = ''
    127.0.0.1 db
    127.0.0.1 redis
  '';

  environment.systemPackages = with pkgs; [
    # utility
    # postman
    # httpie
    # ngrok

	foot

    # communications
    (unstable.discord.override { nss = nss_latest; })
    zoom-us

    # Web Browsers
    google-chrome

    # The worst software in the world
    vscode
    firefox

    (writeShellScriptBin "slack" ''
	  if ${ksshaskpass}/bin/ksshaskpass | sudo -k -S true; then
		  exec ${slack-dark}/bin/slack
	  else
		  exec xdg-open "https://www.youtube.com/watch?v=qdrs3gr_GAs"
	  fi
	'')

  ];
}
