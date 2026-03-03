{ inputs, ... }: final: prev: {
  minimal-tmux = inputs.minimal-tmux.packages.${final.stdenv.hostPlatform.system}.default;
}
