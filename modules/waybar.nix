{ config, lib, pkgs, inputs, ... }:

{
  home-manager.users.excalibur = { pkgs, ... }: {
    programs = {
      waybar = {
        enable = true;
        systemd = {
          enable = true;
        };
        settings = {
          mainBar = {
            layer = "top";
            position = "right";
            spacing = 4;
            mode = "hide";
            start_hidden = true;
            modules-left = ["custom/power-off" "clock" "hyprland/workspaces"];
            modules-center = ["hyprland/window"];
            modules-right = ["mpris" "wireplumber" "network" "bluetooth" "cpu" "memory" "temperature" "backlight" "keyboard-state" "battery" "battery#bat2" "tray"];
            "hyprland/workspaces" = {
              disable-scroll = true;
              all-outputs = true;
              format = "{icon}\n{name}";
              format-icons = {
                "1" = "󱇽";
                "2" = "󰈹";
                "3" = "󰨞";
                "4" = "";
                "11" = "󱗆";
                "12" = "";
                "13" = "";
                "14" = "";
                "15" = "󰊻";
                "20" = "󰝚";
                "30" = "󰍺";
                urgent = "";
                focused = "";
                default = "";
              };
              on-scroll-up = "hyprctl dispatch workspace e-1";
              on-scroll-down = "hyprctl dispatch workspace e+1";
              on-click = "activate";
            };
            "hyprland/window" = {
              rotate = 270;
              separate-outputs = true;
            };
            keyboard-state = {
              numlock = true;
              capslock = true;
              format = {
                capslock = "{icon}\nC";
                numlock = "{icon}\nN";
              };
              format-icons = {
                locked = "";
                unlocked = "";
              };
            };
            mpris = {
              format = "{player_icon}";
              format-paused = "{status_icon}";
              player-icons = {
                default = "▶";
                mpv = "🎵";
              };
              status-icons = {
                paused = "⏸";
              };
            };
            wireplumber = {
              format = "\n{volume}";
              format-muted = "";
              on-click = "pwvucontrol";
            };
            tray = {
              spacing = 10;
            };
            clock = {
              tooltip-format = "<tt><big>{calendar}</big></tt>";
              format = "T{:%H\n :%M}";
              interval = 1;
              calendar = {
                weeks-pos = "left";
                format = {
                  months = "<span color='#ffead3'><b>{}</b></span>";
                  days = "<span color='#ecc6d9'><b>{}</b></span>";
                  weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                  weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                  today = "<span color='#ff6699'><b><u>{}</u></b></span>";
                };
              };
              actions =  {
                on-click-right = "mode";
                on-click-forward = "tz_up";
                on-click-backward = "tz_down";
                on-scroll-up = "shift_up";
                on-scroll-down = "shift_down";
              };
            };
            cpu = {
              format = "\n{usage}";
              on-click = "kitty htop";
            };
            memory = {
              format = "\n{}";
            };
            temperature = {
              hwmon-path = "/sys/class/hwmon/hwmon3/temp1_input";
              critical-threshold = 80;
              format = "{icon}\n{temperatureC}";
              format-icons = ["" "" ""];
            };
            backlight = {
              format = "{icon}\n{percent}";
              format-icons = ["" "" "" "" "" "" "" "" ""];
            };
            battery = {
              states = {
                warning = 30;
                critical = 15;
              };
              format = "{icon}\n{capacity}";
              format-charging = "\n{capacity}";
              format-plugged = "\n{capacity}";
              format-alt = "{time} {icon}";
              format-icons = ["" "" "" "" ""];
            };
            "battery#bat2" = {
              bat = "BAT2";
            };
            network = {
              format-wifi = "";
              format-ethernet = "";
              format-linked = "";
              format-disconnected = "⚠";
              tooltip-format = "{ifname}: {ipaddr}/{cidr} via {gwaddr} \nUp: {bandwidthUpBytes} Down: {bandwidthDownBytes}";
              on-click = "kitty sudo nmtui";
            };
            bluetooth = {
              rotate = 270;
              format = " {status}";
              format-connected = " {device_alias}";
              format-connected-battery = " {device_alias} {device_battery_percentage}%";
              tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
              tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
              tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
              tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
              on-click = "blueman-manager";
            };
            "custom/power-off" = {
              format ="";
              on-click ="systemctl poweroff";
            };
          };
        };
        style = ''
          * {
              /* `otf-font-awesome` is required to be installed for icons */
              font-family: "NotoSans Nerd Font", "Font Awesome 6 Free", "RobotoMono Nerd Font";
              font-size: 13px;
          }

          tooltip {
            background: #282828;
            border: 1px solid #a9b665;
          }

          tooltip label {
            color: #d4be98;
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

          button {
              /* Use box-shadow instead of border so the text isn't offset */
              box-shadow: inset 0 -3px transparent;
              /* Avoid rounded borders under each button name */
              border: none;
              border-radius: 0;
          }

          /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
          button:hover {
              background: inherit;
              box-shadow: inset 0 -3px #ffffff;
          }

          #workspaces button {
              padding: 0 5px;
              background-color: transparent;
              color: #ffffff;
          }

          #workspaces button:hover {
              background: rgba(0, 0, 0, 0.2);
          }

          #workspaces button.active {
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
          #bluetooth,
          #pulseaudio,
          #wireplumber,
          #custom-power-off,
          #tray,
          #mode,
          #idle_inhibitor,
          #scratchpad,
          #mpris,
          #window,
          #mpd {
              padding: 0 10px;
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

          #mpris {
              background-color: #46c5bf;
          }

          #mpris.paused {
              background-color: #f53c3c;
          }

          #wireplumber {
              background-color: #fff0f5;
              color: #000000;
          }

          #wireplumber.muted {
              background-color: #f53c3c;
          }

          #custom-power-off {
              background-color: #be2c2c;
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

          #scratchpad {
              background: rgba(0, 0, 0, 0.2);
          }

          #scratchpad.empty {
            background-color: transparent;
          }
        '';
      };
    };
  };
}
