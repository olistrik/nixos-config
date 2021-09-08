{config, lib, pkgs, ...}:
let
  themer = config.system.themer;
in {
  imports = [

  ];

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [

    ];
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
      for_window [class="^.*"] border pixel 2

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
      bindsym $mod+Shift+exclam     move container to workspace number $ws1
      bindsym $mod+Shift+at         move container to workspace number $ws2
      bindsym $mod+Shift+numbersign move container to workspace number $ws3
      bindsym $mod+Shift+dollar     move container to workspace number $ws4
      bindsym $mod+Shift+percent    move container to workspace number $ws5

      ################################################
      ## Keybindings #################################
      ################################################

      #############
      ## General

      # kill focus window
      bindsym $mod+Shift+q kill

      # reload the config
      bindsym $mod+Shift+c reload

      # restart i3
      bindsym $mod+Shift+r restart

      # exit i3 (logs you out of your X session)
      bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"

      # lock i3
      bindsym $mod+Shift+l exec xautolock -locknow

      #############
      ## Programs

      # Alacritty Terminal
      bindsym $mod+Return exec alacritty
      bindsym $mod+Shift+Return exec alacritty --working-directory $(xcwd)

      # dmenu
      bindsym $mod+space exec rofi -theme Arc-Dark -show run

      # screenshot
      bindsym $mod+p exec screenshot $HOME/Pictures

      # screencrop
      bindsym --release $mod+Shift+p exec screencrop $HOME/Pictures
      bindsym --release $mod+Shift+s exec screencrop $HOME/Pictures

      # screencrop
      bindsym --release $mod+Ctrl+p exec windowshot $HOME/Pictures

      #######################
      ## container Controls

      # change layout
      bindsym $mod+e layout toggle stacking tabbed split
      bindsym $mod+f layout floating toggle

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
      bindsym XF86AudioPlay exec playerctl play-pause
      bindsym XF86AudioNext exec playerctl next

      ###############################################

      bar {
        position top
        tray_output none
        status_command i3blocks -c /etc/i3blocks.conf
        colors {
          background #3c3b3a
        }
      }
    '';
  };
}
