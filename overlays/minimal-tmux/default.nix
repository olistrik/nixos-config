{ inputs, ... }: final: prev: {
  minimal-tmux = inputs.minimal-tmux.packages.${final.system}.default;
}
