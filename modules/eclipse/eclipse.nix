with import <nixpkgs> {};

let unwrapped = pkgs.eclipses.eclipseWithPlugins {
  eclipse = pkgs.eclipses.eclipse-platform;
  jvmArgs = ["-Xmx2048m"];
  plugins = with pkgs.eclipses.plugins; [
    vrapper
  ];
};

in import ./wrapper.nix {
  inherit makeWrapper symlinkJoin;
  eclipse = unwrapped;
}
