{ inputs, ... }: final: prev: {
  ags2 = inputs.ags.packages.${final.stdenv.hostPlatform.system}.agsFull;
}
