{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell {
  name = "My-project build environment";
  buildInputs = lib.mapAttrsToList (name: value: (writeScriptBin name value)) {
    build = ''
      git add -A
      nix-rebuild test --flake ".#"
    '';
    switch = ''
      git add -A
      [[ -z $(git status -s) ]] || git commit
      nixos-rebuild switch --flake ".#"
      [[ -z $(git status -s) ]] || git commit -am "chore: update flake.lock"
      git push
    '';
  };
}
