args@{
  my ? import ./. args,
  ...
}:
{
  # Built against its own nixpkgs pin (the one its CI uses); the Rust toolchain needs a newer
  # wasm-bindgen-cli than the stable channel carries.
  homewire = import my.sources.homewire { };
}
