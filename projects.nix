args@{
  my ? import ./. args,
  ...
}:
{
  homewire = import my.sources.homewire {
    inherit (my.sources) nixpkgs;
  };
}
