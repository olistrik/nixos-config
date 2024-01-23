{ pkgs, ... }:
pkgs.tree-sitter.buildGrammar {
  language = "gotmpl";
  version = "fe6bb98";
  src = pkgs.fetchFromGitHub {
    owner = "ngalaiko";
    repo = "tree-sitter-go-template";
    rev = "fe6bb984fe4f0b1661b24ff613be5163f33b2a19";
    sha256 = "gczwgeL3QdaDXvjVEwpKNzMnWktWEP7OHILx8W5mr9A=";
  };
}
