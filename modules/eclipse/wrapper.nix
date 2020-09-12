{ makeWrapper, symlinkJoin, eclipse }:

symlinkJoin {
  name = "elcipse";
  paths = [ eclipse ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/eclipse \
      --set GTK_THEME Raleigh
  '';
}
