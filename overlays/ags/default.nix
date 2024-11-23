{ inputs, ... }: final: prev: {
  ags2 = inputs.ags.packages.${final.system}.agsFull;
}
