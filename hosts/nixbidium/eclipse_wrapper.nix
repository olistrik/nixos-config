{symlinkJoin, makeWrapper, eclipse}:

pkgs.symlinkJoin {
 name = "eclipse";
 paths = [ eclipse ];
 buildInputs = [ makeWrapper ];
 postBuild = ''
   wrapProgram $out/bin/eclipse \
     --set GTK_THEME Raleigh
 '';
}
