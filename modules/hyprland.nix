{ config, lib, pkgs, inputs, ... }:

{
  security.pam.services.hyprlock = {};
  home-manager.users.excalibur = { pkgs, ... }: {
    home.pointerCursor.hyprcursor = {
      enable = true;
      size = 32;
    };
    systemd.user = {
      services = {
        hyprlock = {
          Unit = {
            Description = "Hyprland's GPU-accelerated screen locking utility";

            # If hyprlock exits cleanly, unlock the session:
            OnSuccess = ["unlock.target"];

            # When lock.target is stopped, stops this too:
            PartOf = ["lock.target"];

            # Delay lock.target until this service is ready:
            Before = ["lock.target"];
          };
          Install = {
            WantedBy = ["lock.target"];
          };
          Service = {
            # systemd will consider this service started when hyprlock forks...
            Type = "forking";

            # ... and hyprlock will fork only after it has locked the screen.
            ExecStart = "${lib.getExe pkgs.hyprlock}";

            # If hyprlock crashes, always restart it immediately:
            Restart = "on-failure";
            RestartSec = 0;
          };
        };
      };
    };
    programs = {
      hyprlock = {
        enable = true;
        settings = {
          general = {
            grace = 10;
            hide_cursor = true;
          };

          background = [
            {
              path = "~/.config/hypr/lockscreen.png";
              color = "rgba(160, 160, 160, 1.0)";
            }
          ];

          input-field = [
            {
              size = "250, 60";
              dots_size = 0.2;
              dots_spacing = 0.2;
              dots_center = true;
              font_color = "rgba(200, 200, 200, 1.0)";
              inner_color = "rgba(0, 0, 0, 0.5)";
              outer_color = "rgba(0, 0, 0, 0)";
              outline_thickness = 2;
              shadow_passes = 2;
              fade_on_empty = false;
              font_family = "JetBrains Mono Nerd Font Mono";
              hide_input = false;
              position = "0, -120";
              halign = "center";
              valign = "center";
            }
          ];

          label = [
            {
              text = "cmd[update:1000] echo $(date +%T)";
              color = "rgba(0, 0, 0, 0.6)";
              font_size = 120;
              font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
              position = "0, -300";
              halign = "center";
              valign = "top";
            }
            {
              text = "$USER";
              color = "rgba(255, 255, 255, 1.0)";
              font_size = 25;
              font_family = "JetBrains Mono Nerd Font Mono";
              position = "0, -40";
              halign = "center";
              valign = "center";
            }
            {
              text = "AUTHORIZED ACCESS ONLY";
              color = "rgba(255, 0, 0, 1.0)";
              font_size = 18;
              font_family = "JetBrains Mono Nerd Font Mono";
              position = "0, 0";
              halign = "center";
              valign = "bottom";
            }
          ];
        };
      };
    };
    services = {
      hyprpaper = {
        enable = true;
        settings = {
          ipc = "on";
          splash = false;

          preload = [
            "~/.config/hypr/wallpaper.jpg"
          ];

          wallpaper = [
            ", ~/.config/hypr/wallpaper.jpg"
          ];
        };
      };
      hypridle = {
        enable = true;
        settings = {
          general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };

          listener = [
            {
              timeout = 600;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 1800;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        };
      };
    };
    wayland.windowManager.hyprland = {
      enable = true;
      plugins = [
        pkgs.hyprlandPlugins.hyprgrass
      ];
      systemd = {
        enable = true;
        enableXdgAutostart = true;
      };
      settings = {
        ecosystem = {
          no_update_news = "yes";
        };
        env = [
          "AQ_DRM_DEVICES,/dev/dri/card-mali:/dev/dri/card-intel:/dev/dri/card-amd:/dev/dri/card-nvidia"
        ];
        input = {
          kb_layout = "us";
          numlock_by_default = "yes";
        };
        exec-once = [
          "fcitx5"
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"
          "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          "[workspace 2 silent] firefox"
        ];
        general = {
          gaps_in = 0;
          gaps_out = 0;
          resize_on_border = "yes";
          border_size = 1;
        };
        animations = {
          enabled = "no";
        };
        dwindle = {
          pseudotile = "yes";
          smart_split = "yes";
        };
        misc = {
          vrr = 2;
          force_default_wallpaper = 2;
          allow_session_lock_restore = true;
        };
        windowrulev2 = [
          "idleinhibit fullscreen, class:^(.*)$, title:^(.*)$"
          "float, class:^(.*)$, title:^(Open File)$"
          "float, class:^(.*)$, title:^(Open Folder)$"
          "float, class:^(.*)$, title:^(Picture)$" # Feishu
          "float, class:^(\.scrcpy-wrapped)$, title:^(.*)$"
          "float, class:^(com\.alibabainc\.dingtalk)$, title:^(com\.alibabainc\.dingtalk)$"
          "float, class:^(heroic)$, title:^(Heroic Games Launcher)$"
          "float, class:^(org\.kde\.kcalc)$, title:^(KCalc)$"
          "float, class:^(thunderbird)$, title:^(Authentication Required - Mozilla Thunderbird)$"
          "float, class:^(thunderbird)$, title:^(Write\: .*)$"
          "float, class:^(thunderbird)$, title:^(Calendar Reminders)$"
          "float, class:^(thunderbird)$, title:^(Edit Item)$"
          "float, class:^(\.virt-manager-wrapped)$, title:^(.* on QEMU/KVM)$"
          "float, class:^(Bytedance-feishu)$, title:^()$"
          "float, class:^(org\.gnome\.Calculator)$, title:^(Calculator)$"
          "float, class:^(nwg-displays)$, title:^(nwg-displays)$"
          "float, class:^(net\.lutris\.Lutris)$, title:^(Select an EXE or MSI file)$"
          "float, class:^(zenity)$, title:^(.*)$"
          "float, class:^(battle\.net\.exe)$, title:^(Battle\.net.*)$"
          "float, class:^(heroesprofile\.uploader\.exe)$, title:^(Heroesprofile\.com Uploader v.*)$"
          "float, class:^(xdg-desktop-portal-gtk)$, title:^(.*)$"
          "float, class:^(steam)$, title:^(.*)$"
          "stayfocused, class:^(Pinentry)$"
          "fullscreen, class:^(Waydroid)$, title:^(Waydroid)$"
          "fullscreen, class:^(heroesofthestorm_x64\.exe)$, title:^(Heroes of the Storm)$"
          "workspace 1 silent, class:^(steam_app_default)$, title:^(二重螺旋  )$"
          "workspace 1 silent, class:^(steam_app_default)$, title:^(MainWnd)$"
          "workspace 1 silent, class:^(heroesofthestorm_x64\.exe)$, title:^(Heroes of the Storm)$"
          "workspace 3 silent, class:^(battle\.net\.exe)$, title:^(Battle\.net)$"
          "workspace 3 silent, class:^(battle\.net\.exe)$, title:^(Battle\.net Login)$"
          "workspace 3 silent, class:^(steam_app_default)$, title:^(Chaos Zero Nightmare)$"
          "workspace 3 silent, class:^(steam_app_default)$, title:^(STOVE)$"
          "renderunfocused, class:^(steam_app_default)$, title:^(Chaos Zero Nightmare)$"
          "workspace 4 silent, class:^(battle\.net\.exe)$, title:^(Battle\.net - Chats and Groups)$"
          "workspace 10 silent, class:^(com\.alibabainc\.dingtalk)$, title:^(升级提醒)$"
          "workspace 10 silent, class:^(explorer\.exe)$, title:^()$"
          "workspace 10 silent, class:^(explorer\.exe)$, title:^(Wine System Tray)$"
          "workspace 10 silent, class:^(steam_app_default)$, title:^()$"
          "workspace 10 silent, class:^(steam_app_default)$, title:^(TransparentWind)$"
          "workspace 10 silent, class:^(steam_app_default)$, title:^(FloatingStripWnd)$"
          "workspace 10 silent, class:^(heroesprofile\.uploader\.exe)$, title:^(Heroesprofile\.com Uploader v.*)$"
          "workspace 11 silent, class:^(.*)$, title:^(Feishu)$"
          "workspace 13 silent, class:^(Waydroid)$, title:^(Waydroid)$"
          "workspace 16 silent, class:^(com\.alibabainc\.dingtalk)$, title:^(钉钉)$"
          "workspace 17 silent, class:^(QQ)$, title:^(QQ)$"
          "workspace 18 silent, class:^(wechat)$, title:^(Weixin)$"
          "workspace 18 silent, class:^(wechat)$, title:^(微信)$"
          "workspace 19 silent, class:^(steam)$, title:^(Sign in to Steam)$"
          "workspace 19 silent, class:^(steam)$, title:^(Special Offers)$"
          "workspace 19 silent, class:^(steam)$, title:^(Steam)$"
          "workspace 19 silent, class:^()$, title:^(Steam)$"
        ];
        "$mainMod" = "SUPER";
        "$menu" = "nwg-drawer -term kitty -nofs";
        bind = [
          "$mainMod, Q, exec, kitty"
          "$mainMod, C, killactive, "
          "$mainMod, M, exit,"
          "$mainMod, E, exec, dolphin"
          "$mainMod, F, fullscreen, 0"
          "$mainMod, V, togglefloating,"
          "$mainMod, R, exec, $menu"
          "$mainMod, P, pseudo, # dwindle"
          "$mainMod, J, togglesplit, # dwindle"
          "$mainMod, L, exec, loginctl lock-session"
          "$mainMod SHIFT, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"
          "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          "$mainMod SHIFT, left, movewindow, l"
          "$mainMod SHIFT, right, movewindow, r"
          "$mainMod SHIFT, up, movewindow, u"
          "$mainMod SHIFT, down, movewindow, d"
          "$mainMod SHIFT, left, layoutmsg, togglesplit"
          "$mainMod SHIFT, right, layoutmsg, togglesplit"
          "$mainMod SHIFT, up, layoutmsg, togglesplit"
          "$mainMod SHIFT, down, layoutmsg, togglesplit"
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"
          "$mainMod, kp_end, workspace, 11"
          "$mainMod, kp_down, workspace, 12"
          "$mainMod, kp_next, workspace, 13"
          "$mainMod, kp_left, workspace, 14"
          "$mainMod, kp_begin, workspace, 15"
          "$mainMod, kp_right, workspace, 16"
          "$mainMod, kp_home, workspace, 17"
          "$mainMod, kp_up, workspace, 18"
          "$mainMod, kp_prior, workspace, 19"
          "$mainMod, kp_insert, workspace, 20"
          "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
          "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
          "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
          "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
          "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
          "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
          "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
          "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
          "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
          "$mainMod SHIFT, 0, movetoworkspacesilent, 10"
          "$mainMod SHIFT, kp_end, movetoworkspacesilent, 11"
          "$mainMod SHIFT, kp_down, movetoworkspacesilent, 12"
          "$mainMod SHIFT, kp_next, movetoworkspacesilent, 13"
          "$mainMod SHIFT, kp_left, movetoworkspacesilent, 14"
          "$mainMod SHIFT, kp_begin, movetoworkspacesilent, 15"
          "$mainMod SHIFT, kp_right, movetoworkspacesilent, 16"
          "$mainMod SHIFT, kp_home, movetoworkspacesilent, 17"
          "$mainMod SHIFT, kp_up, movetoworkspacesilent, 18"
          "$mainMod SHIFT, kp_prior, movetoworkspacesilent, 19"
          "$mainMod SHIFT, kp_insert, movetoworkspacesilent, 20"
          "$mainMod, prior, workspace, e-1"
          "$mainMod, next, workspace, e+1"
          "$mainMod SHIFT, prior, movetoworkspace, e-1"
          "$mainMod SHIFT, next, movetoworkspace, e+1"
          "$mainMod, mouse_down, workspace, e-1"
          "$mainMod, mouse_up, workspace, e+1"
          "$mainMod SHIFT, mouse_down, movetoworkspace, e-1"
          "$mainMod SHIFT, mouse_up, movetoworkspace, e+1"
          ", XF86Search, exec, fsearch"
          ", XF86Display, exec, nwg-displays --num_ws 30"
          #", XF86WLAN, exec, kitty"
          #", XF86Tools, exec, kitty"
          #", XF86Launch1, exec, kitty"
          #", XF86LaunchA, exec, kitty"
          #", XF86Explorer, exec, kitty"
          ", XF86Calculator, exec, kcalc"
          ", XF86FullScreen, fullscreen, 0"
          #", XF86Sleep, exec, hyprlock"
          ", XF86HomePage, exec, firefox"
          "$mainMod ALT, space, exec, pkill -SIGUSR1 waybar"
        ];
        binde = [
          "$mainMod CTRL, right, resizeactive, 10 0"
          "$mainMod CTRL, left, resizeactive, -10 0"
          "$mainMod CTRL, up, resizeactive, 0 -10"
          "$mainMod CTRL, down, resizeactive, 0 10"
        ];
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, Control_L, movewindow"
          "$mainMod, mouse:273, resizewindow"
          "$mainMod, ALT_L, resizewindow"
        ];
        bindl = [
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && notify-send \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@)\""
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && notify-send \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@)\""
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && notify-send \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@)\""
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && notify-send \"$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)\""
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioStop, exec, playerctl stop"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
        ];
        bindel = [
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ];
        plugin = {
          touch_gestures = {
            hyprgrass-bind = [
              ", tap:3, sendshortcut, mouse:274"
              ", swipe:3:l, sendshortcut, mouse:275"
              ", swipe:3:r, sendshortcut, mouse:276"
            ];
          };
        };
        source = [
          "~/.config/hypr/monitors.conf"
          "~/.config/hypr/workspaces.conf"
        ];
      };
    };
  };
}
