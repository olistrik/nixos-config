{ config, lib, pkgs, ... }:
let themer = config.system.themer;
in {
  imports = [ ../programs/waybar ];

  services.xserver = {
    enable = true;
    libinput.enable = true;
    displayManager = {
      defaultSession = "sway";
      gdm = {
        enable = true;
        wayland = true;
      };
    };
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swayidle
      swaylock-effects
      wofi
      xwayland
      kanshi
      grim
      jq
      slurp
      wl-clipboard
      playerctl

      (pkgs.writeScriptBin "lock" ''
                ${swaylock-effects}/bin/swaylock -f --image "$HOME/screensaver" 
        		--clock \
                --indicator-radius 100 \
                --indicator-thickness 7 \
                --ring-color 455a64 \
                --key-hl-color be5046 \
                --text-color ffc107 \
                --line-color 00000000 \
                --inside-color 00000088 \
                --separator-color 00000000 \
                --fade-in 0.1
                "$@"
      '')
      (pkgs.writeScriptBin "ssh-add-all" ''
        exec ls -d ~/.ssh/* | grep -vE 'known_hosts|.pub$'| xargs ssh-add
      '')
    ];

    extraSessionCommands = ''
      export MOZ_ENABLE_WAYLAND=1
      export _JAVA_AWT_WM_NONREPARENTING=1
      systemctl --user import-environment
    '';
  };

  environment = {
    etc."sway/config".source = pkgs.writeText "sway-config" ''
      ################################################
      ##  i3 cnfig   #################################
      ################################################

      # Set modifier key to windows
      set $mod Mod4

      # focus following is really annoying
      focus_follows_mouse no

      # set gaps
      gaps inner ${builtins.toString themer.wm.gaps.inner}
      gaps outer ${builtins.toString themer.wm.gaps.outer}
      gaps top -4

      # Set font
      font pango:JetBrains Mono NerdFont 10

      # Move floating windows with Mouse + MOD
      floating_modifier $mod

      # hide window titles
      default_border pixel 2

      # auto split orientation
      # default_orientation auto

      ################################################
      ## Workspaces  #################################
      ################################################

      # Set workspace names
      set $ws1 "1"
      set $ws2 "2"
      set $ws3 "3"
      set $ws4 "4"
      set $ws5 "5"

      # switch workspace
      bindsym $mod+1 workspace number $ws1
      bindsym $mod+2 workspace number $ws2
      bindsym $mod+3 workspace number $ws3
      bindsym $mod+4 workspace number $ws4
      bindsym $mod+5 workspace number $ws5

      # send container to workspace
      bindsym $mod+Shift+1 move container to workspace number $ws1
      bindsym $mod+Shift+2 move container to workspace number $ws2
      bindsym $mod+Shift+3 move container to workspace number $ws3
      bindsym $mod+Shift+4 move container to workspace number $ws4
      bindsym $mod+Shift+5 move container to workspace number $ws5

      ################################################
      ## Keybindings #################################
      ################################################

      #############
      ## General

      # kill focus window
      bindsym $mod+Shift+q kill

      # reload the config
      bindsym $mod+Shift+c reload

      # lock i3
      bindsym $mod+Shift+l exec lock

      #############
      ## Programs

      # Alacritty Terminal
      bindsym $mod+Return exec alacritty
      bindsym $mod+Shift+Return exec alacritty --working-directory $(xcwd)

      # wofi run menu
      bindsym $mod+space exec wofi --gtk-dark --show run

      # screenshot
      bindsym $mod+p exec grim - | wl-copy -t image/png

      # screencrop
      bindsym $mod+Shift+p exec grim -g "$(slurp)" - | wl-copy -t image/png
      bindsym $mod+Shift+s exec grim -g "$(slurp)" - | wl-copy -t image/png

      # windowshot
      bindsym $mod+Ctrl+p exec grim -g "$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')" - | wl-copy -t image/png

      #######################
      ## container Controls

      # change layout
      bindsym $mod+e layout toggle tabbed split

      # split controls
      bindsym $mod+apostrophe split toggle

      bindsym $mod+j resize shrink width 20
      bindsym $mod+k resize shrink height 20
      bindsym $mod+l resize grow height 20
      bindsym $mod+semicolon resize grow width 20

      bindsym $mod+Up focus up
      bindsym $mod+Down focus down
      bindsym $mod+Left focus left
      bindsym $mod+Right focus right

      bindsym $mod+Shift+Up move up
      bindsym $mod+Shift+Down move down
      bindsym $mod+Shift+Left move left
      bindsym $mod+Shift+Right move right

      #####################
      ## Audio Controls

      bindsym XF86AudioRaiseVolume exec --no-startup-id "amixer -q sset Master,0 5%+ unmute"
      bindsym XF86AudioLowerVolume exec --no-startup-id "amixer -q sset Master,0 5%- unmute"
      bindsym XF86AudioMute exec --no-startup-id "amixer -q sset Master,0 toggle"
      bindsym --locked XF86AudioPlay exec playerctl play-pause
      bindsym XF86AudioNext exec playerctl next

      #################################
      ## backgrounds and transparency

      set $solid 1.0
      set $opacity 0.8

      for_window [class=".*"] opacity $solid
      for_window [app_id="firefox" title="Picture-in-Picture"] floating enable
      # for_window [app_id=".*"] opacity $opacity

      output * bg $HOME/wallpaper fill

      ##########################
      ## Background Programs

      exec waybar
      exec kanshi
      exec swayidle -w \
      	timeout 300 'lock --grace 5 --fade-in 4' \
      	timeout 600 'swaymsg "output * dpms off"' \
      	resume 'swaymsg "output * dpms on"' \
      	before-sleep 'lock'

      exec ssh-add-all
    '';
  };
}
