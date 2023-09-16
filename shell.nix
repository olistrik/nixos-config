{ pkgs ? import <nixpkgs> { } }:

with pkgs;
mkShell {
  name = "My-project build environment";
  buildInputs = lib.mapAttrsToList (name: value: (writeScriptBin name value)) {
    test = ''
      	  echo "HELLO"
            git add -A
            nix-rebuild test --flake ".#"
    '';
    switch = ''
      git add -A
      [[ -z $(git status -s) ]] || git commit
      sudo nixos-rebuild switch --flake ".#"
      [[ -z $(git status -s) ]] || git commit -am "chore: update flake.lock"
      git push
    '';
  };
  shellHook = ''
    echo "Welcome in $name"
    export FOO="BAR"
  '';
}
