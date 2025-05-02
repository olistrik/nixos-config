{ inputs, ... }: final: prev: {
  nix-search = inputs.nix-search.packages.${final.system}.default;
}
