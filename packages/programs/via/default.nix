{ pkgs, lib, appimageTools, fetchurl }:

appimageTools.wrapType2 rec {
  name = "via";
  version = "1.3.1";

  src = fetchurl {
    url = "https://github.com/the-via/releases/releases/download/v${version}/via-${version}-linux.AppImage";
    sha256 = "sha256-0s1z0oCiZRSf7bJBYex8V1UjWWxNMImK1rWHXgmz80o=";
  };

  extraPkgs = pkgs: with pkgs; [ lxqt.lxqt-policykit ];

  extraInstallCommands = ''
    # PATCHING RUN AS SUDO
    # --------------------
    # where to find the node.js librar .asar was described here https://github.com/NixOS/nixpkgs/issues/76526#issuecomment-569131432
    packed="$out/resources/app/node_modules.asar"
    # we unpack directly into the same name without .asar ending,
    # which is adapted from hacking-skype-tutorial https://www.codepicky.com/hacking-electron-restyle-skype/
    unpacked="$out/resources/app/node_modules"
    
    ${pkgs.nodePackages.asar}/bin/asar extract "$packed" "$unpacked"
    # we change paths to pkexec and bash
    # as described here https://github.com/NixOS/nixpkgs/blob/fc553c0bc5411478e2448a707f74369ae9351e96/pkgs/tools/misc/etcher/default.nix#L49y
    sed -i "
      s|/usr/bin/pkexec|/run/wrappers/bin/pkexec|
      s|/bin/bash|${pkgs.bash}/bin/bash|
    " "$unpacked/sudo-prompt/index.js"
    # delete original .asar file, as the new unpacked is now replacing it
    rm -rf "$packed"
  '';
}
