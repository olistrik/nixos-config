{ pkgs }:
with pkgs; {
  go-nvim = callPackage ./go-nvim { };
  scss-syntax-vim = callPackage ./scss-syntax-vim { };
  exrc-nvim = callPackage ./exrc-nvim { };
}
