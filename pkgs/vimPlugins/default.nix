{ pkgs }:
with pkgs; {
  go-nvim = callPackage ./go-nvim { };
  scss-syntax-vim = callPackage ./scss-syntax-vim { };
}
