{ lib, ... }:
with lib; {
  packages = pkgs: {
    alias = name: pkg: pkgs.writeShellScriptBin name ''
      exec ${getExe pkg} $@
    '';
  };
}
