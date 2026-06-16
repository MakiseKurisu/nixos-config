{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  security.pam.services.hyprlock = { };
  home-manager.users.excalibur =
    { pkgs, ... }:
    {
      home.pointerCursor.hyprcursor = {
        enable = true;
        size = 32;
      };
      systemd.user = {
        services = {
          hyprlock = {
            Unit = {
              Description = "Hyprland's GPU-accelerated screen locking utility";

              # When lock.target is stopped, stops this too:
              PartOf = [ "lock.target" ];

              # Delay lock.target until this service is ready:
              Before = [ "lock.target" ];
            };
            Install = {
              WantedBy = [ "lock.target" ];
            };
            Service = {
              # systemd will consider this service started when hyprlock forks...
              Type = "forking";

              # ... and hyprlock will fork only after it has locked the screen.
              ExecStart = "${lib.getExe pkgs.hyprlock} --grace 10";

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
            ipc = true;
            splash = false;

            wallpaper = [
              {
                monitor = "";
                path = "~/.config/hypr/wallpaper.jpg";
              }
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
        configType = "hyprlang";
        enable = true;
        plugins = [
          # pkgs.hyprlandPlugins.hyprgrass
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
            smart_split = "yes";
          };
          misc = {
            vrr = 2;
            force_default_wallpaper = 2;
            allow_session_lock_restore = true;
            render_unfocused_fps = 30;
          };
          windowrule = [
            "idle_inhibit fullscreen, match:class ^(.*)$, match:title ^(.*)$"
            "no_focus yes, match:class ^(com-eteks-sweethome3d-SweetHome3DBootstrap)$, match:title ^(win1)$"
            "float yes, match:class ^(com\.DreamSourceLab\.www\.)$, match:title ^(DSView)$"
            "float yes, match:class ^(.*)$, match:title ^(Open File)$"
            "float yes, match:class ^(.*)$, match:title ^(Open Folder)$"
            "float yes, match:class ^(.*)$, match:title ^(Picture)$" # Feishu
            "float yes, match:class ^(\.scrcpy-wrapped)$, match:title ^(.*)$"
            "float yes, match:class ^(com\.alibabainc\.dingtalk)$, match:title ^(com\.alibabainc\.dingtalk)$"
            "float yes, match:class ^(file-.*)$, match:title ^(Export Image as .*)$"
            "float yes, match:class ^(file-.*)$, match:title ^(Load .* Image)$"
            "float yes, match:class ^(heroic)$, match:title ^(Heroic Games Launcher)$"
            "float yes, match:class ^(org\.kde\.kcalc)$, match:title ^(KCalc)$"
            "float yes, match:class ^(thunderbird)$, match:title ^(Authentication Required - Mozilla Thunderbird)$"
            "float yes, match:class ^(thunderbird)$, match:title ^(Write\: .*)$"
            "float yes, match:class ^(thunderbird)$, match:title ^(Calendar Reminders)$"
            "float yes, match:class ^(thunderbird)$, match:title ^(Edit Item)$"
            "float yes, match:class ^(\.virt-manager-wrapped)$, match:title ^(.* on QEMU/KVM)$"
            "float yes, match:class ^(Bytedance-feishu)$, match:title ^()$"
            "float yes, match:class ^(org\.gnome\.Calculator)$, match:title ^(Calculator)$"
            "float yes, match:class ^(nwg-displays)$, match:title ^(nwg-displays)$"
            "float yes, match:class ^(net\.lutris\.Lutris)$, match:title ^(Select an EXE or MSI file)$"
            "float yes, match:class ^(zenity)$, match:title ^(.*)$"
            "float yes, match:class ^(battle\.net\.exe)$, match:title ^(Battle\.net.*)$"
            "float yes, match:class ^(steam_app_default)$, match:title ^(Heroesprofile\.com Uploader v.*)$"
            "float yes, match:class ^(heroesprofile\.uploader\.exe)$, match:title ^(Heroesprofile\.com Uploader v.*)$"
            "float yes, match:class ^(xdg-desktop-portal-gtk)$, match:title ^(.*)$"
            "float yes, match:class ^(steam)$, match:title ^(.*)$"
            "float yes, match:class ^(stove\.exe)$, match:title ^(STOVE)$"
            "stay_focused yes, match:class ^(Pinentry)$"
            "fullscreen yes, match:class ^(Waydroid)$, match:title ^(Waydroid)$"
            "fullscreen yes, match:class ^(heroesofthestorm_x64\.exe)$, match:title ^(Heroes of the Storm)$"
            "fullscreen yes, match:class ^(steam_app_default)$, match:title ^(Heroes of the Storm)$"
            "workspace 1 silent, match:class ^(steam_app_0)$, match:title ^(二重螺旋  )$"
            "workspace 1 silent, match:class ^(steam_app_0)$, match:title ^(MainWnd)$"
            "workspace 1 silent, match:class ^(steam_app_0)$, match:title ^(Endfield)$"
            "workspace 1 silent, match:class ^(heroesofthestorm_x64\.exe)$, match:title ^(Heroes of the Storm)$"
            "workspace 1 silent, match:class ^(steam_app_default)$, match:title ^(Heroes of the Storm)$"
            "workspace 1 silent, match:class ^(steam_app_default)$, match:title ^(异环  )$"
            "workspace 3 silent, match:class ^(battle\.net\.exe)$, match:title ^(Battle\.net)$"
            "workspace 3 silent, match:class ^(steam_app_default)$, match:title ^(Battle\.net)$"
            "workspace 3 silent, match:class ^(battle\.net\.exe)$, match:title ^(Battle\.net Login)$"
            "workspace 3 silent, match:class ^(steam_app_default)$, match:title ^(Battle\.net Login)$"
            "workspace 3 silent, match:class ^(ssr-stove-shield\.exe)$, match:title ^(Chaos Zero Nightmare)$"
            "workspace 3 silent, match:class ^(steam_app_default)$, match:title ^(Chaos Zero Nightmare)$"
            "workspace 3 silent, match:class ^(stove\.exe)$, match:title ^(STOVE)$"
            "workspace 3 silent, match:class ^(steam_app_default)$, match:title ^(STOVE)$"
            "workspace 3 silent, match:class ^(steam_app_0)$, match:title ^(鹰角启动器)$"
            "workspace 3 silent, match:class ^(steam_app_0)$, match:title ^(更新程序)$"
            "workspace 3 silent, match:class ^(steam_app_0)$, match:title ^(Dialog - 鹰角启动器)$"
            "workspace 3 silent, match:class ^(steam_app_default)$, match:title ^(异环启动器)$"
            "workspace 3 silent, match:class ^(steam_app_default)$, match:title ^(异环启动器 更新)$"
            "render_unfocused yes, match:class ^(ssr-stove-shield\.exe)$, match:title ^(Chaos Zero Nightmare)$"
            "render_unfocused yes, match:class ^(steam_app_default)$, match:title ^(Chaos Zero Nightmare)$"
            "render_unfocused yes, match:class ^(steam_app_0)$, match:title ^(二重螺旋  )$"
            "render_unfocused yes, match:class ^(steam_app_default)$, match:title ^(异环  )$"
            "workspace 4 silent, match:class ^(battle\.net\.exe)$, match:title ^(Battle\.net - Chats and Groups)$"
            "workspace 4 silent, match:class ^(steam_app_default)$, match:title ^(Battle\.net - Chats and Groups)$"
            "workspace 10 silent, match:class ^(com\.alibabainc\.dingtalk)$, match:title ^(升级提醒)$"
            "workspace 10 silent, match:class ^(explorer\.exe)$, match:title ^()$"
            "workspace 10 silent, match:class ^(explorer\.exe)$, match:title ^(Wine System Tray)$"
            "workspace 10 silent, match:class ^(steam_app_0)$, match:title ^()$"
            "workspace 10 silent, match:class ^(steam_app_0)$, match:title ^(TransparentWind)$"
            "workspace 10 silent, match:class ^(steam_app_0)$, match:title ^(FloatingStripWnd)$"
            "workspace 10 silent, match:class ^(steam_app_default)$, match:title ^()$"
            "workspace 10 silent, match:class ^(steam_app_default)$, match:title ^(Heroesprofile\.com Uploader v.*)$"
            "workspace 10 silent, match:class ^(heroesprofile\.uploader\.exe)$, match:title ^(Heroesprofile\.com Uploader v.*)$"
            "workspace 10 silent, match:class ^(steam_app_0)$, match:title ^(Form)$"
            "workspace 11 silent, match:class ^(.*)$, match:title ^(Feishu)$"
            "workspace 13 silent, match:class ^(Waydroid)$, match:title ^(Waydroid)$"
            "workspace 16 silent, match:class ^(com\.alibabainc\.dingtalk)$, match:title ^(钉钉)$"
            "workspace 17 silent, match:class ^(QQ)$, match:title ^(QQ)$"
            "workspace 18 silent, match:class ^(wechat)$, match:title ^(Weixin)$"
            "workspace 18 silent, match:class ^(wechat)$, match:title ^(微信)$"
            "workspace 19 silent, match:class ^(steam)$, match:title ^(Sign in to Steam)$"
            "workspace 19 silent, match:class ^(steam)$, match:title ^(Special Offers)$"
            "workspace 19 silent, match:class ^(steam)$, match:title ^(Steam)$"
            "workspace 19 silent, match:class ^()$, match:title ^(Steam)$"
          ];
          "$mainMod" = "SUPER";
          "$menu" = "nwg-drawer -i breeze -term kitty -nofs";
          bind = [
            "$mainMod, Q, exec, kitty"
            "$mainMod, C, killactive, "
            "$mainMod, M, exit,"
            "$mainMod, E, exec, dolphin"
            "$mainMod, F, fullscreen, 0"
            "$mainMod, V, togglefloating,"
            "$mainMod, R, exec, $menu"
            "$mainMod, P, pseudo, # dwindle"
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
            ", Print, exec, grim -o \"$(hyprctl activeworkspace -j | jq -r '.monitor')\" - | wl-copy"
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
