{ config, lib, pkgs, inputs, ... }:

{
  home-manager.users.excalibur = { pkgs, ... }: {
    wayland.windowManager.hyprland = {
      enable = true;
      plugins = [
        pkgs.unstable.hyprlandPlugins.hyprgrass
      ];
      systemd = {
        enableXdgAutostart = true;
      };
      extraConfig = ''
        exec-once = waybar & hyprpaper & fcitx5 & discord --start-minimized
        exec-once = wl-paste --type text --watch cliphist store
        exec-once = wl-paste --type image --watch cliphist store
        exec-once = wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ & wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        exec-once = [workspace 1 silent] looking-glass-client
        exec-once = [workspace 2 silent] firefox
        exec-once = [workspace 11 silent] gtk-launch bytedance-feishu
        exec-once = [workspace 12 silent] thunderbird
        exec-once = [workspace 13 silent] waydroid first-launch
        exec-once = [workspace 14 silent] element-desktop
        exec-once = [workspace 15 silent] teams-for-linux
        exec-once = [workspace 20 silent] yesplaymusic

        input {
            kb_layout = us
            numlock_by_default = yes
        }

        general {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more

            gaps_in = 0
            gaps_out = 0
            resize_on_border = yes
            border_size = 1
        }

        animations {
            enabled = no
        }

        dwindle {
            # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
            pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            smart_split = yes # you probably want this
        }

        misc {
            vrr = 1
            force_default_wallpaper = 2
        }

        # Example windowrule v1
        # windowrule = float, ^(kitty)$
        # Example windowrule v2
        # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        windowrulev2 = float, title:(KCalc), class:(org.kde.kcalc)
        windowrulev2 = float, title:(Open File)
        windowrulev2 = float, title:(Open Folder)
        windowrulev2 = float, title:(Picture) # Feishu
        windowrulev2 = fullscreen, title:(Waydroid), class:(Waydroid)
        windowrulev2 = workspace 11 silent, title:(Feishu)
        windowrulev2 = workspace 13 silent, title:(Waydroid), class:(Waydroid)

        # See https://wiki.hyprland.org/Configuring/Keywords/ for more
        $mainMod = SUPER
        $menu = nwg-drawer -term kitty

        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
        bind = $mainMod, Q, exec, kitty
        bind = $mainMod, C, killactive, 
        bind = $mainMod, M, exit, 
        bind = $mainMod, E, exec, dolphin
        bind = $mainMod, F, fullscreen, 0
        bind = $mainMod, V, togglefloating, 
        bind = $mainMod, R, exec, $menu
        bind = $mainMod, P, pseudo, # dwindle
        bind = $mainMod, J, togglesplit, # dwindle
        bind = $mainMod, L, exec, hyprlock
        bind = $mainMod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy
        bind = $mainMod SHIFT, S, exec, grim -g "$(slurp)" - | wl-copy

        # Move focus with mainMod + arrow keys
        bind = $mainMod, left, movefocus, l
        bind = $mainMod, right, movefocus, r
        bind = $mainMod, up, movefocus, u
        bind = $mainMod, down, movefocus, d

        # Move window with mainMod + SHIFT + arrow keys
        bind = $mainMod SHIFT, left, movewindow, l
        bind = $mainMod SHIFT, right, movewindow, r
        bind = $mainMod SHIFT, up, movewindow, u
        bind = $mainMod SHIFT, down, movewindow, d
        bind = $mainMod SHIFT, left, layoutmsg, togglesplit
        bind = $mainMod SHIFT, right, layoutmsg, togglesplit
        bind = $mainMod SHIFT, up, layoutmsg, togglesplit
        bind = $mainMod SHIFT, down, layoutmsg, togglesplit

        # Resize window with mainMod + CTRL + arrow keys
        binde= $mainMod CTRL, right, resizeactive, 10 0
        binde= $mainMod CTRL, left, resizeactive, -10 0
        binde= $mainMod CTRL, up, resizeactive, 0 -10
        binde= $mainMod CTRL, down, resizeactive, 0 10

        # Switch workspaces with mainMod + [0-9]
        bind = $mainMod, 1, workspace, 1
        bind = $mainMod, 2, workspace, 2
        bind = $mainMod, 3, workspace, 3
        bind = $mainMod, 4, workspace, 4
        bind = $mainMod, 5, workspace, 5
        bind = $mainMod, 6, workspace, 6
        bind = $mainMod, 7, workspace, 7
        bind = $mainMod, 8, workspace, 8
        bind = $mainMod, 9, workspace, 9
        bind = $mainMod, 0, workspace, 10
        bind = $mainMod, kp_end, workspace, 11
        bind = $mainMod, kp_down, workspace, 12
        bind = $mainMod, kp_next, workspace, 13
        bind = $mainMod, kp_left, workspace, 14
        bind = $mainMod, kp_begin, workspace, 15
        bind = $mainMod, kp_right, workspace, 16
        bind = $mainMod, kp_home, workspace, 17
        bind = $mainMod, kp_up, workspace, 18
        bind = $mainMod, kp_prior, workspace, 19
        bind = $mainMod, kp_insert, workspace, 20

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        bind = $mainMod SHIFT, 1, movetoworkspacesilent, 1
        bind = $mainMod SHIFT, 2, movetoworkspacesilent, 2
        bind = $mainMod SHIFT, 3, movetoworkspacesilent, 3
        bind = $mainMod SHIFT, 4, movetoworkspacesilent, 4
        bind = $mainMod SHIFT, 5, movetoworkspacesilent, 5
        bind = $mainMod SHIFT, 6, movetoworkspacesilent, 6
        bind = $mainMod SHIFT, 7, movetoworkspacesilent, 7
        bind = $mainMod SHIFT, 8, movetoworkspacesilent, 8
        bind = $mainMod SHIFT, 9, movetoworkspacesilent, 9
        bind = $mainMod SHIFT, 0, movetoworkspacesilent, 10
        bind = $mainMod SHIFT, kp_end, movetoworkspacesilent, 11
        bind = $mainMod SHIFT, kp_down, movetoworkspacesilent, 12
        bind = $mainMod SHIFT, kp_next, movetoworkspacesilent, 13
        bind = $mainMod SHIFT, kp_left, movetoworkspacesilent, 14
        bind = $mainMod SHIFT, kp_begin, movetoworkspacesilent, 15
        bind = $mainMod SHIFT, kp_right, movetoworkspacesilent, 16
        bind = $mainMod SHIFT, kp_home, movetoworkspacesilent, 17
        bind = $mainMod SHIFT, kp_up, movetoworkspacesilent, 18
        bind = $mainMod SHIFT, kp_prior, movetoworkspacesilent, 19
        bind = $mainMod SHIFT, kp_insert, movetoworkspacesilent, 20

        # Scroll through existing workspaces with mainMod + scroll
        bind = $mainMod, mouse_down, workspace, e-1
        bind = $mainMod, mouse_up, workspace, e+1

        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, Control_L, movewindow
        bindm = $mainMod, mouse:273, resizewindow
        bindm = $mainMod, ALT_L, resizewindow

        # Multimedia keys
        bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        bindl = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        bindl = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        bindl = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

        bindel = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
        bindel = , XF86MonBrightnessUp, exec, brightnessctl set 5%+

        bindl = , XF86AudioPlay, exec, playerctl play-pause
        bindl = , XF86AudioStop, exec, playerctl stop
        bindl = , XF86AudioNext, exec, playerctl next
        bindl = , XF86AudioPrev, exec, playerctl previous

        # Shortcut keys
        #bind = , XF86Display, exec, kcalc
        #bind = , XF86WLAN, exec, kcalc
        #bind = , XF86Tools, exec, kcalc
        bind = , XF86Search, exec, fsearch
        #bind = , XF86LaunchA, exec, kcalc
        #bind = , XF86Explorer, exec, kcalc

        bind = , XF86Calculator, exec, kcalc
        bind = , XF86FullScreen, fullscreen, 0
        #bind = , XF86Sleep, exec, hyprlock
        bind = , XF86HomePage, exec, firefox

        # Toggle waybar display
        bind = $mainMod ALT, space, exec, pkill -SIGUSR1 waybar

        plugin:touch_gestures {
            hyprgrass-bind = , tap:3, sendshortcut, mouse:274
            hyprgrass-bind = , swipe:3:l, sendshortcut, mouse:275
            hyprgrass-bind = , swipe:3:r, sendshortcut, mouse:276
        }

        source = ~/.config/hypr/machine.conf
      '';
    };
  };
}
