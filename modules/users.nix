{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./users-base.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.excalibur = { pkgs, ... }: {
      imports = [
        inputs.nixos-vscode-server.homeModules.default
      ];
      xdg = {
        enable = true;
        configFile = {
          "hypr" = {
            source = ../configs/hypr;
            recursive = true;
          };
          "discord" = {
            source = ../configs/discord;
            recursive = true;
          };
          "LarkShell" = {
            source = ../configs/LarkShell;
            recursive = true;
          };
          "gtk-3.0/settings.ini" = {
            text = ''
              [Settings]
              gtk-im-module=fcitx
            '';
          };
          "gtk-4.0/settings.ini" = {
            text = ''
              [Settings]
              gtk-im-module=fcitx
            '';
          };
        };
        userDirs = {
          enable = true;
          createDirectories = true;
        };
      };
      home = {
        username = "excalibur";
        homeDirectory = "/home/excalibur";
        stateVersion = "22.11";
      };
      programs = {
        home-manager.enable = true;
        bash = {
          enable = true;
          historyControl = [
            "ignoredups"
            "ignorespace"
          ];
          enableVteIntegration = true;
          bashrcExtra = ''
            picocom() {
              env picocom -b ''${1:-1500000} /dev/ttyUSB0
            }
          '';
        };
        bashmount.enable = true;
        starship = {
          enable = true;
          enableBashIntegration = true;
        };
        direnv = {
          enable = true;
          enableBashIntegration = true;
          nix-direnv.enable = true;
        };
        fzf = {
          enable = true;
          enableBashIntegration = true;
          tmux.enableShellIntegration = true;
        };
        tmux = {
          enable = true;
          mouse = true;
          newSession = true;
        };
        kitty = {
          enable = true;
          settings = {
            confirm_os_window_close = 0;
            paste_actions = "quote-urls-at-prompt";
            scrollback_pager_history_size = 128;
          };
          shellIntegration.enableBashIntegration = true;
        };
        obs-studio = {
          enable = true;
          plugins = with pkgs.obs-studio-plugins; [
            input-overlay
            looking-glass-obs
            obs-pipewire-audio-capture
            wlrobs
            obs-vaapi
            obs-vkcapture
            obs-multi-rtmp
            obs-backgroundremoval
          ];
        };
        vscode = {
          enable = true;
          package = (pkgs.vscode.override (previous: {
            commandLineArgs = (previous.commandLineArgs or "") +
              " --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --enable-wayland-ime --password-store=gnome --disable-gpu-sandbox";
          }));
          profiles.default = {
            enableExtensionUpdateCheck = false;
            enableUpdateCheck = false;
            extensions = with pkgs.vscode-extensions; [
              bbenoist.nix
              github.vscode-github-actions
              github.vscode-pull-request-github
              ms-azuretools.vscode-docker
              ms-dotnettools.csdevkit
              ms-dotnettools.csharp
              ms-python.python
              ms-vscode.cmake-tools
              ms-vscode.cpptools
              ms-vscode.cpptools-extension-pack
              ms-vscode.hexeditor
              ms-vscode.makefile-tools
              ms-vscode.powershell
              pkgs.unstable.vscode-extensions.ms-vscode.remote-explorer
              ms-vscode-remote.remote-containers
              ms-vscode-remote.remote-ssh
              ms-vscode-remote.remote-ssh-edit
              ms-vscode-remote.vscode-remote-extensionpack
              ms-vsliveshare.vsliveshare
              unifiedjs.vscode-mdx
            ];
            userSettings = {
              "debug.javascript.unmapMissingSources" = true;
              "diffEditor.ignoreTrimWhitespace" = false;
              "editor.fontFamily" = "'Droid Sans Mono', 'monospace', monospace, 'NotoSans Nerd Font', 'Font Awesome 6 Free', 'RobotoMono Nerd Font'";
              "editor.rulers" = [
                80
              ];
              "editor.selectionClipboard" = false;
              "editor.stickyScroll.enabled" = true;
              "files.autoGuessEncoding" = true;
              "files.autoSave" = "afterDelay";
              "git.autofetch" = true;
              "git.confirmSync" = false;
              "git.enableSmartCommit" = true;
              "window.titleBarStyle" = "custom";
              "makefile.configureOnOpen" = true;
              "explorer.confirmDragAndDrop" = false;
              "workbench.welcomePage.walkthroughs.openOnInstall" = false;
            };
          };
        };
        thunderbird = {
          enable = true;
          settings = {
            "calendar.events.defaultActionEdit" = true;
            "mail.default_send_format" = 1;
            "mail.identity.default.compose_html" = false;
            "privacy.donottrackheader.enabled" = true;
          };
          profiles = {
            default = {
              isDefault = true;
              withExternalGnupg = true;
            };
          };
        };
      };
      services = {
        dunst = {
          enable = true;
          settings = {
            global = {
              follow = "mouse";
              origin = "top-center";
              offset = "(0, 50)";
            };
          };
        };
        vscode-server.enable = true;
      };
      accounts.email.accounts = {
        "yt@radxa.com" = {
          realName = "ZHANG Yuntian";
          userName = "yt@radxa.com";
          address = "yt@radxa.com";
          primary = true;
          imap = {
            host = "imap.exmail.qq.com";
            port = 993;
          };
          smtp = {
            host = "smtp.exmail.qq.com";
            port = 465;
          };
          gpg = {
            key = "26CE4D9E745813BE33E6154757116E87EF0460A7";
            signByDefault = true;
          };
          signature = {
            showSignature = "append";
            text = ''
              Best regards,

              ZHANG, Yuntian

              Operating System Developer
              Radxa Computer (Shenzhen) Co., Ltd
              Shenzhen, China
            '';
          };
          thunderbird = {
            enable = true;
          };
        };
      };
    };
  };
}
