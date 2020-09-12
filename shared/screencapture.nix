{ pkgs, ... }:

let
  screenshot = pkgs.writeScriptBin "screenshot" ''
    #!${pkgs.stdenv.shell}
    LOC="."
    if [ "$#" == 1 ]; then
        LOC=$1
        echo $1
    fi

    FILE="$(date +%Y%m%d-%H%M%S)"

    import -window root "$LOC/screenshot_$FILE.png"
    xclip -selection clipboard -t image/png -i "$LOC/screenshot_$FILE.png"
  '';
  screencrop = pkgs.writeScriptBin "screencrop" ''
    #!${pkgs.stdenv.shell}
    LOC="."
    if [ "$#" == 1 ]; then
        LOC=$1;
    fi

    FILE="$(date +%Y%m%d-%H%M%S)"

    import "$LOC/screenshot_$FILE.png"
    xclip -selection clipboard -t image/png -i "$LOC/screenshot_$FILE.png"
  '';
  windowshot= pkgs.writeScriptBin "windowshot" ''
    #!${pkgs.stdenv.shell}
    LOC="."
    if [ "$#" == 1 ]; then
        LOC=$1
        echo $1
    fi

    FILE="$(date +%Y%m%d-%H%M%S)"

    WINDOW="$(xwininfo | grep 'Window id' | awk '{print $4}')"

    import -window $WINDOW "$LOC/screenshot_$FILE.png"
    xclip -selection clipboard -t image/png -i "$LOC/screenshot_$FILE.png"
  '';
in {
  environment.systemPackages = with pkgs; [
    imagemagick
    xdotool
    xorg.xwininfo
    xclip
    screenshot
    screencrop
    windowshot
  ];
}
