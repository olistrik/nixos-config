{ pkgs }:
with pkgs; {
  tree-sitter-go-template = callPackage ./tree-sitter-go-template { };
}
