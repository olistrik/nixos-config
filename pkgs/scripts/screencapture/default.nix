{ stdenv, symlinkJoin, writeScriptBin, imagemagick, xdotool, xorg, xclip }:

let
  screenshot = writeScriptBin "screenshot" ''
    #!${stdenv.shell}
    LOC="."
    if [ "$#" == 1 ]; then
        LOC=$1
        echo $1
    fi

    FILE="$(date +%Y-%m-%dT%H%M)"
    COUNT="$(ls $LOC | grep $FILE.* | wc -l)"

    ${imagemagick}/bin/import -window root "$LOC/screenshot_$FILE.$COUNT.png"
    ${xclip}/bin/xclip -selection clipboard -t image/png -i "$LOC/screenshot_$FILE.$COUNT.png"
  '';
  screencrop = writeScriptBin "screencrop" ''
    #!${stdenv.shell}
    LOC="."
    if [ "$#" == 1 ]; then
        LOC=$1;
    fi

    FILE="$(date +%Y-%m-%dT%H%M)"
    COUNT="$(ls $LOC | grep $FILE.* | wc -l)"

    ${imagemagick}/bin/import "$LOC/screenshot_$FILE.$COUNT.png"
    ${xclip}/bin/xclip -selection clipboard -t image/png -i "$LOC/screenshot_$FILE.$COUNT.png"
  '';
  windowshot= writeScriptBin "windowshot" ''
    #!${stdenv.shell}
    LOC="."
    if [ "$#" == 1 ]; then
        LOC=$1
        echo $1
    fi

    FILE="$(date +%Y-%m-%dT%H%M)"
    COUNT="$(ls $LOC | grep $FILE.* | wc -l)"

    WINDOW="$(${xorg.xwininfo}/bin/xwininfo | grep 'Window id' | awk '{print $4}')"

    ${imagemagick}/bin/import -window $WINDOW "$LOC/screenshot_$FILE.$COUNT.png"
    ${xclip}/bin/xclip -selection clipboard -t image/png -i "$LOC/screenshot_$FILE.$COUNT.png"
  '';
in symlinkJoin {
  name = "screencapture-scripts";
  paths = [ screenshot screencrop windowshot ];
}
