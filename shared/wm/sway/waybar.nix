{config, lib, pkgs, ...}:
let
  themer = config.system.themer;
in {
  environment.systemPackages = with pkgs; [
    waybar
  ];

  programs.waybar.enable = true;

  environment = {
    etc."xdg/waybar/config".source = pkgs.writeText "sway-config" ''
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
  };
}
