{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./users-base.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.excalibur =
      { pkgs, ... }:
      {
        imports = [
          inputs.nixos-vscode-server.homeModules.default
        ];
        xdg = {
          enable = true;
          configFile = {
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
                gtk-theme-name=Breeze
                gtk-icon-theme-name=breeze
                gtk-font-name=Adwaita Sans 11
                gtk-cursor-theme-name=Breeze_Light
                gtk-cursor-theme-size=24
              '';
            };
            "gtk-4.0/settings.ini" = {
              text = ''
                [Settings]
                gtk-im-module=fcitx
                gtk-theme-name=Breeze
                gtk-icon-theme-name=breeze
                gtk-font-name=Adwaita Sans 11
                gtk-cursor-theme-name=Breeze_Light
                gtk-cursor-theme-size=24
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
          stateVersion = lib.mkDefault config.system.stateVersion;
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
                env picocom -b ''${1:-1500000} /dev/ttyACM0
              }
              flashrom() {
                env flashrom -p ch347_spi -w "$@"
              }
            '';
          };
          bashmount.enable = true;
          starship = {
            enable = true;
            enableBashIntegration = true;
            settings = {
              shlvl = {
                disabled = false;
                threshold = 1;
              };
              cmd_duration.show_notifications = true;
              status.disabled = false;
            };
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
          htop = {
            enable = true;
            settings = {
              hide_kernel_threads = false;
              show_cpu_frequency = true;
              show_cpu_temperature = true;
              column_meters_0 = "LeftCPUs Memory Swap Zram DiskIO";
              column_meter_modes_0 = "1 1 1 1 2";
              column_meters_1 = "RightCPUs Tasks LoadAverage Uptime NetworkIO";
              column_meter_modes_1 = "1 2 2 2 2";
            };
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
              (lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") looking-glass-obs)
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
            package = (
              pkgs.vscode.override (previous: {
                commandLineArgs =
                  (previous.commandLineArgs or "")
                  + " --ozone-platform-hint=auto --enable-features=UseOzonePlatform,WaylandWindowDecorations,TouchpadOverscrollHistoryNavigation --gtk-version=4 --enable-features=WaylandPerSurfaceScale,WaylandUiScale --enable-wayland-ime --wayland-text-input-version=3 --password-store=gnome --disable-gpu-sandbox";
              })
            );
            profiles.default = {
              enableExtensionUpdateCheck = false;
              enableUpdateCheck = false;
              extensions = with pkgs.vscode-extensions; [
                anthropic.claude-code
                github.vscode-github-actions
                github.vscode-pull-request-github
                jnoortheen.nix-ide
                ms-azuretools.vscode-containers
                ms-dotnettools.csdevkit
                ms-dotnettools.csharp
                ms-dotnettools.vscode-dotnet-runtime
                ms-python.python
                ms-vscode.cmake-tools
                ms-vscode.cpptools
                ms-vscode.cpptools-extension-pack
                ms-vscode.hexeditor
                ms-vscode.makefile-tools
                ms-vscode.powershell
                ms-vscode.remote-explorer
                ms-vscode-remote.remote-containers
                ms-vscode-remote.remote-ssh
                ms-vscode-remote.remote-ssh-edit
                ms-vscode-remote.vscode-remote-extensionpack
                ms-vsliveshare.vsliveshare
                unifiedjs.vscode-mdx
              ];
              userSettings = {
                "claudeCode.environmentVariables" = [
                  {
                    name = "ANTHROPIC_BASE_URL";
                    value = "https://api.minimaxi.com/anthropic";
                  }
                  {
                      name = "ANTHROPIC_AUTH_TOKEN";
                      value = "<MINIMAX_API_KEY>";
                  }
                  {
                    name = "API_TIMEOUT_MS";
                    value = 3000000;
                  }
                  {
                    name = "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC";
                    value = 1;
                  }
                  {
                    name = "ANTHROPIC_MODEL";
                    value = "MiniMax-M2.5";
                  }
                  {
                    name = "ANTHROPIC_SMALL_FAST_MODEL";
                    value = "MiniMax-M2.5";
                  }
                  {
                    name = "ANTHROPIC_DEFAULT_SONNET_MODEL";
                    value = "MiniMax-M2.5";
                  }
                  {
                    name = "ANTHROPIC_DEFAULT_OPUS_MODEL";
                    value = "MiniMax-M2.5";
                  }
                  {
                    name = "ANTHROPIC_DEFAULT_HAIKU_MODEL";
                    value = "MiniMax-M2.5";
                  }
                ];
                "claudeCode.preferredLocation" = "sidebar";
                "claudeCode.selectedModel" = "MiniMax-M2.5";
                "debug.javascript.unmapMissingSources" = true;
                "diffEditor.ignoreTrimWhitespace" = false;
                "diffEditor.maxComputationTime" = 30000;
                "editor.fontFamily" =
                  "'Droid Sans Mono', 'monospace', monospace, 'NotoSans Nerd Font', 'Font Awesome 6 Free', 'RobotoMono Nerd Font'";
                "editor.formatOnPaste" = true;
                "editor.rulers" = [
                  80
                ];
                "editor.selectionClipboard" = false;
                "editor.stickyScroll.enabled" = true;
                "explorer.confirmDragAndDrop" = false;
                "files.autoGuessEncoding" = true;
                "files.autoSave" = "afterDelay";
                "git.autofetch" = true;
                "git.confirmSync" = false;
                "git.enableSmartCommit" = true;
                "git.replaceTagsWhenPull" = true;
                "makefile.configureOnOpen" = true;
                "nix.enableLanguageServer" = true;
                "nix.serverPath" = "nixd";
                "terminal.integrated.scrollback" = 5000;
                "update.showReleaseNotes" = false;
                "window.titleBarStyle" = "custom";
                "workbench.secondarySideBar.defaultVisibility" = "hidden";
                "workbench.welcomePage.walkthroughs.openOnInstall" = false;
                "[nix]" = {
                  "editor.formatOnSave" = true;
                };
              };
            };
          };
          thunderbird = {
            enable = true;
            settings = {
              "calendar.events.defaultActionEdit" = true;
              "mail.default_send_format" = 1; # plain text
              "mail.identity.default.compose_html" = false;
              "mail.identity.default.doCc" = true; # enable Cc field by default
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
                dmenu = "${lib.getExe pkgs.tofi} --prompt-text dunst";
                browser = "${lib.getExe' pkgs.xdg-utils "xdg-open"}";
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
              perIdentitySettings = id: {
                "mail.identity.id_${id}.fcc" = false; # do not save sent mail to "Sent" folder
                "mail.identity.id_${id}.reply_to" = "yt@radxa.com";
              };
            };
          };
        };
      };
  };
}
