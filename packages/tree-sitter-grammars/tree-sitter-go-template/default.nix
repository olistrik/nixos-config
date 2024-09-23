{ pkgs, ... }:
pkgs.tree-sitter.buildGrammar rec {
  language = "gotmpl";
  version = "fe6bb98";
  src = pkgs.fetchFromGitHub {
    owner = "ngalaiko";
    repo = "tree-sitter-go-template";
    rev = "${version}";
    sha256 = "gczwgeL3QdaDXvjVEwpKNzMnWktWEP7OHILx8W5mr9A=";
  };
}
