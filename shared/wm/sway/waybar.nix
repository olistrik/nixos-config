{config, lib, pkgs, ...}:
let
  themer = config.system.themer;

  style = ''
    * {
        border: none;
        border-radius: 0;
        /* `otf-font-awesome` is required to be installed for icons */
        font-family: Roboto, Helvetica, Arial, sans-serif;
        font-size: 13px;
        min-height: 0;
    }

    window#waybar {
        background-color: rgba(43, 48, 59, 0.5);
        border-bottom: 3px solid rgba(100, 114, 125, 0.5);
        color: #ffffff;
        transition-property: background-color;
        transition-duration: .5s;
    }

    window#waybar.hidden {
        opacity: 0.2;
    }

    /*
    window#waybar.empty {
        background-color: transparent;
    }
    window#waybar.solo {
        background-color: #FFFFFF;
    }
    */

    window#waybar.termite {
        background-color: #3F3F3F;
    }

    window#waybar.chromium {
        background-color: #000000;
        border: none;
    }

    #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #ffffff;
        /* Use box-shadow instead of border so the text isn't offset */
        box-shadow: inset 0 -3px transparent;
    }

    /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
    #workspaces button:hover {
        background: rgba(0, 0, 0, 0.2);
        box-shadow: inset 0 -3px #ffffff;
    }

    #workspaces button.focused {
        background-color: #64727D;
        box-shadow: inset 0 -3px #ffffff;
    }

    #workspaces button.urgent {
        background-color: #eb4d4b;
    }

    #mode {
        background-color: #64727D;
        border-bottom: 3px solid #ffffff;
    }

    #clock,
    #battery,
    #cpu,
    #memory,
    #disk,
    #temperature,
    #backlight,
    #network,
    #pulseaudio,
    #custom-media,
    #tray,
    #mode,
    #idle_inhibitor,
    #mpd {
        padding: 0 10px;
        margin: 0 4px;
        color: #ffffff;
    }

    #window,
    #workspaces {
        margin: 0 4px;
    }

    /* If workspaces is the leftmost module, omit left margin */
    .modules-left > widget:first-child > #workspaces {
        margin-left: 0;
    }

    /* If workspaces is the rightmost module, omit right margin */
    .modules-right > widget:last-child > #workspaces {
        margin-right: 0;
    }

    #clock {
        background-color: #64727D;
    }

    #battery {
        background-color: #ffffff;
        color: #000000;
    }

    #battery.charging, #battery.plugged {
        color: #ffffff;
        background-color: #26A65B;
    }

    @keyframes blink {
        to {
            background-color: #ffffff;
            color: #000000;
        }
    }

    #battery.critical:not(.charging) {
        background-color: #f53c3c;
        color: #ffffff;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
    }

    label:focus {
        background-color: #000000;
    }

    #cpu {
        background-color: #2ecc71;
        color: #000000;
    }

    #memory {
        background-color: #9b59b6;
    }

    #disk {
        background-color: #964B00;
    }

    #backlight {
        background-color: #90b1b1;
    }

    #network {
        background-color: #2980b9;
    }

    #network.disconnected {
        background-color: #f53c3c;
    }

    #pulseaudio {
        background-color: #f1c40f;
        color: #000000;
    }

    #pulseaudio.muted {
        background-color: #90b1b1;
        color: #2a5c45;
    }

    #custom-media {
        background-color: #66cc99;
        color: #2a5c45;
        min-width: 100px;
    }

    #custom-media.custom-spotify {
        background-color: #66cc99;
    }

    #custom-media.custom-vlc {
        background-color: #ffa000;
    }

    #temperature {
        background-color: #f0932b;
    }

    #temperature.critical {
        background-color: #eb4d4b;
    }

    #tray {
        background-color: #2980b9;
    }

    #tray > .passive {
        -gtk-icon-effect: dim;
    }

    #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #eb4d4b;
    }

    #idle_inhibitor {
        background-color: #2d3436;
    }

    #idle_inhibitor.activated {
        background-color: #ecf0f1;
        color: #2d3436;
    }

    #mpd {
        background-color: #66cc99;
        color: #2a5c45;
    }

    #mpd.disconnected {
        background-color: #f53c3c;
    }

    #mpd.stopped {
        background-color: #90b1b1;
    }

    #mpd.paused {
        background-color: #51a37a;
    }

    #language {
        background: #00b093;
        color: #740864;
        padding: 0 5px;
        margin: 0 5px;
        min-width: 16px;
    }

    #keyboard-state {
        background: #97e1ad;
        color: #000000;
        padding: 0 0px;
        margin: 0 5px;
        min-width: 16px;
    }

    #keyboard-state > label {
        padding: 0 5px;
    }

    #keyboard-state > label.locked {
        background: rgba(0, 0, 0, 0.2);
    }
    '';

    config = ''
    {
        "layer": "top", // Waybar at top layer
        "position": "top", // Waybar position (top|bottom|left|right)
        "height": 30, // Waybar height (to be removed for auto height)

        // Choose the order of the modules
        "modules-left": ["sway/workspaces", "sway/mode", "custom/media"],
        "modules-center": ["sway/window"],
        "modules-right": ["pulseaudio", "network", "battery", "clock"],
        "sway/mode": {
            "format": "<span style=\"italic\">{}</span>"
        },
        "clock": {
            // "timezone": "America/New_York",
            "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
            "format-alt": "{:%Y-%m-%d}"
        },
        "battery": {
            "states": {
                // "good": 95,
                "warning": 30,
                "critical": 15
            },
            "format": "{capacity}% {icon}",
            "format-charging": "{capacity}% ",
            "format-plugged": "{capacity}% ",
            "format-alt": "{time} {icon}",
            // "format-good": "", // An empty format will hide the module
            "format-full": "",
            "format-icons": ["", "", "", "", ""]
        },
        "network": {
            // "interface": "wlp2*", // (Optional) To force the use of this interface
            "format-wifi": "{essid} ({signalStrength}%) ",
            "format-ethernet": "{ifname}: {ipaddr}/{cidr} ",
            "format-linked": "{ifname} (No IP) ",
            "format-disconnected": "Disconnected ⚠",
            "format-alt": "{ifname} {ipaddr}/{cidr}"
        },
        "pulseaudio": {
            // "scroll-step": 1, // %, can be a float
            "format": "{volume}% {icon} {format_source}",
            "format-bluetooth": "{volume}% {icon} {format_source}",
            "format-bluetooth-muted": " {icon} {format_source}",
            "format-muted": " {format_source}",
            "format-source": "{volume}% ",
            "format-source-muted": "",
            "format-icons": {
                "headphone": "",
                "hands-free": "",
                "headset": "",
                "phone": "",
                "portable": "",
                "car": "",
                "default": ["", "", ""]
            },
            "on-click": "pavucontrol"
        },
    }
    '';

    modules = [];
in {
  environment.systemPackages = with pkgs; [
    waybar
  ];

  programs.waybar.enable = true;

  environment = {
    etc."xdg/waybar/style.css".source = pkgs.writeText "waybar-style"
      (builtins.catAttrs "style" modules) + style;

    etc."xdg/waybar/config".source = pkgs.writeText "waybar-config"
      (builtins.catAttrs "config" modules) + config;

  };
}
