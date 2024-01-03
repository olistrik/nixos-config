{ pkgs, ... }:

let
  chucknorris = pkgs.writeScriptBin "chucknorris" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.wget}/bin/wget http://api.icndb.com/jokes/random -qO- | ${pkgs.jshon}/bin/jshon -e value -e joke -u | fold -s'';

in {
  environment.systemPackages = with pkgs; [
    chucknorris
    jshon
    wget
  ];
}
