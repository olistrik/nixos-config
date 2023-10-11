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

    # communications
    (unstable.discord.override { nss = nss_latest; })
    zoom-us

    # Web Browsers
    google-chrome

    # The worst software in the world
    vscode
    firefox
    postman

    (writeShellScriptBin "slack"
      "exec ${google-chrome}/bin/google-chrome-stable https://www.youtube.com/watch?v=qdrs3gr_GAs")

    (writeShellScriptBin "cake" "exec ${slack-dark}/bin/slack")
  ];
}
