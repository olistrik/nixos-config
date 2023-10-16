{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell {
  name = "util scripts";
  buildInputs = lib.mapAttrsToList (name: value: (writeScriptBin name value)) {
    build = ''
      git add -A
      nixos-rebuild test --flake ".#"
    '';
    switch = ''
      git add -A
      [[ -z $(git status -s) ]] || git commit
      nixos-rebuild switch --flake ".#"
      [[ -z $(git status -s) ]] || git commit -am "chore: update flake.lock"
      git push
    '';
    fix-perms = ''
      chown -R root:wheel ../nixos
      find ../nixos -type d -exec chmod 775 {} +
      find ../nixos -type f -exec chmod 664 {} +
      find ../nixos/scripts -type f -exec chmod 755 {} +
    '';
    update = "nix flake update";
    build-iso = "sudo nix build .#liveUsb";
  };
}
