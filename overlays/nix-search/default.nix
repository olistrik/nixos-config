{ inputs, ... }: final: prev: {
  nix-search = inputs.nix-search.packages.${final.stdenv.hostPlatform.system}.default;
}
