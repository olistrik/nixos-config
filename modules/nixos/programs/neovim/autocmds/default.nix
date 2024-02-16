{ lib, ... }:
let
  indentOverride = pattern: expandTab: spaces: {
    inherit pattern;
    event = [ "FileType" ];
    command = lib.concatStringsSep " " [
      "setlocal"
      "tabstop=${toString spaces}"
      "softtabstop=${toString spaces}"
      "shiftwidth=${toString spaces}"
      (if expandTab then "expandtab" else "noexpandtab")
    ];
  };
in
{
  programs.nixvim.autoCmd = [
    (indentOverride [ "nix" ] true 2)
  ];
}
