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
      { pkgs, ... }@inputs':
      {
        imports = [
          inputs.omniflake.flakes.nixos-vscode-server.homeModules.default
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
            "opencode/oh-my-openagent.json" = {
              text = builtins.toJSON {
                "$schema" =
                  "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json";
                agents = {
                  sisyphus-junior = {
                    model = "xai/grok-4.6";
                    fallback_models = [
                      { model = "minimax-cn-coding-plan/MiniMax-M3"; }
                    ];
                  };
                };

                # Limit expensive providers; let cheap ones run freely
                background_task = {
                  providerConcurrency = {
                    anthropic = 3;
                    deepseek = 3;
                    kimi-for-coding = 3;
                    minimax-cn-coding-plan = 20;
                    moonshotai-cn = 3;
                    nvidia = 3;
                    openai = 3;
                    opencode = 20;
                    xai = 20;
                    xiaomi-token-plan-cn = 20;
                  };
                };

                experimental = {
                  aggressive_truncation = true;
                  task_system = true;
                };
              };
            };
          };
          userDirs = {
            enable = true;
            createDirectories = true;
            setSessionVariables = false;
          };
        };
        home = {
          file = {
            ".local/share/opencode/auth.json" = {
              source =
                inputs'.config.lib.file.mkOutOfStoreSymlink
                  inputs'.config.sops.templates."opencode-auth.json".path;
            };
          };
          username = "excalibur";
          homeDirectory = "/home/excalibur";
          sessionVariables = {
            # desktop
            KDEHOME = "${inputs'.config.xdg.configHome}/kde";
            XCOMPOSECACHE = "${inputs'.config.xdg.cacheHome}/X11/xcompose";
            ERRFILE = "${inputs'.config.xdg.cacheHome}/X11/xsession-errors";
            WINEPREFIX = "${inputs'.config.xdg.dataHome}/wine";

            # programs
            GNUPGHOME = "${inputs'.config.xdg.dataHome}/gnupg";
            LESSHISTFILE = "${inputs'.config.xdg.dataHome}/less/history";
            CUDA_CACHE_PATH = "${inputs'.config.xdg.cacheHome}/nv";
            STEPPATH = "${inputs'.config.xdg.dataHome}/step";
            WAKATIME_HOME = "${inputs'.config.xdg.configHome}/wakatime";
            INPUTRC = "${inputs'.config.xdg.configHome}/readline/inputrc";
            PLATFORMIO_CORE_DIR = "${inputs'.config.xdg.dataHome}/platformio";
            DOTNET_CLI_HOME = "${inputs'.config.xdg.dataHome}/dotnet";
            NUGET_PACKAGES = "${inputs'.config.xdg.cacheHome}/NuGetPackages";
            OMNISHARPHOME = "${inputs'.config.xdg.configHome}/omnisharp";
            MPLAYER_HOME = "${inputs'.config.xdg.configHome}/mplayer";
            SQLITE_HISTORY = "${inputs'.config.xdg.cacheHome}/sqlite_history";

            # programming
            ANDROID_HOME = "${inputs'.config.xdg.dataHome}/android";
            ANDROID_USER_HOME = "${inputs'.config.xdg.dataHome}/android";
            GRADLE_USER_HOME = "${inputs'.config.xdg.dataHome}/gradle";
            IPYTHONDIR = "${inputs'.config.xdg.configHome}/ipython";
            JUPYTER_CONFIG_DIR = "${inputs'.config.xdg.configHome}/jupyter";
            GOPATH = "${inputs'.config.xdg.dataHome}/go";
            M2_HOME = "${inputs'.config.xdg.dataHome}/m2";
            CARGO_HOME = "${inputs'.config.xdg.dataHome}/cargo";
            RUSTUP_HOME = "${inputs'.config.xdg.dataHome}/rustup";
            STACK_ROOT = "${inputs'.config.xdg.dataHome}/stack";
            STACK_XDG = 1;
            NODE_REPL_HISTORY = "${inputs'.config.xdg.dataHome}/node_repl_history";
            NPM_CONFIG_CACHE = "${inputs'.config.xdg.cacheHome}/npm";
            NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
            NPM_CONFIG_USERCONFIG = "${inputs'.config.xdg.configHome}/npm/config";
          };
          stateVersion = lib.mkDefault config.system.stateVersion;
        };
        programs = {
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
              flashrom() {
                env flashrom -p ch347_spi:spispeed=15M -w "$@"
              }
            '';
          };
          bashmount.enable = true;
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
          home-manager = {
            enable = true;
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
          kitty = {
            enable = true;
            settings = {
              confirm_os_window_close = 0;
              paste_actions = "quote-urls-at-prompt";
              scrollback_pager_history_size = 128;
            };
            shellIntegration.enableBashIntegration = true;
          };
          mcp = {
            enable = true;
          };
          obs-studio = {
            enable = true;
            plugins = with inputs'.pkgs.obs-studio-plugins; [
              input-overlay
              (lib.mkIf (inputs'.pkgs.stdenv.hostPlatform.system == "x86_64-linux") looking-glass-obs)
              obs-pipewire-audio-capture
              wlrobs
              obs-vaapi
              obs-vkcapture
              obs-multi-rtmp
              obs-backgroundremoval
            ];
          };
          opencode = {
            context = ''
              # Global OpenCode Rules

              When a command is missing from the shell, use
              `nix run nixpkgs#<package> -- <arguments>`to launch it, instead of
              installing it locally.

              Try identify if a repository is for a Radxa Debian package. They
              usually have origin remote under GitHub radxa-pkg orginazation,
              provide `deb` target in the root Makefile, and contain devcontainer
              configuration. For those repository, use `radxa-deb-package` skill
              to build the package.

              Radxa Debian package repo usually has source code under `src`. It
              is either a normal source dump, a git submodule, or a folder
              containing multiple git submodules.
            '';
            enable = true;
            enableMcpIntegration = true;
            settings = {
              autoupdate = false;
              lsp = true;
              model = "xai/grok-4.6";
              mcp = {
                konnect = {
                  type = "local";
                  command = [
                    "/home/excalibur/.local/share/kicad/10.0/3rdparty/plugins/com_github_mixelpixx_konnect/bin/konnect"
                  ];
                  enabled = true;
                  environment = {
                    RUST_LOG = "info";
                  };
                };
              };
              plugin = [
                "@mohak34/opencode-notifier@latest"
                "oh-my-openagent"
                "opencode-mem"
                "opencode-pty"
                "opencode-wakatime"
              ];
              provider = {
                deepseek = {
                  options = {
                    baseURL = "http://sub2api.vamrs.org:8080/v1";
                    headerTimeout = 60000;
                    chunkTimeout = 60000;
                  };
                };
                kimi-for-coding = {
                  options = {
                    baseURL = "http://sub2api.vamrs.org:8080/v1";
                    headerTimeout = 60000;
                    chunkTimeout = 60000;
                  };
                };
                moonshotai-cn = {
                  options = {
                    baseURL = "http://sub2api.vamrs.org:8080/v1";
                    headerTimeout = 60000;
                    chunkTimeout = 60000;
                  };
                };
                openai = {
                  options = {
                    baseURL = "http://sub2api.vamrs.org:8080/v1";
                    headerTimeout = 60000;
                    chunkTimeout = 60000;
                  };
                };
                xai = {
                  options = {
                    baseURL = "http://sub2api.vamrs.org:8080/v1";
                    headerTimeout = 60000;
                    chunkTimeout = 60000;
                  };
                };
                xiaomi-token-plan-cn = {
                  options = {
                    baseURL = "http://sub2api.vamrs.org:8080/v1";
                    headerTimeout = 60000;
                    chunkTimeout = 60000;
                  };
                };
              };
            };
          };
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
          tmux = {
            enable = true;
            mouse = true;
            newSession = true;
          };
          vscode = {
            enable = true;
            profiles.default = {
              enableExtensionUpdateCheck = false;
              enableUpdateCheck = false;
              extensions = with inputs'.pkgs.vscode-extensions; [
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
                woberg.godot-dotnet-tools
              ];
              keybindings = [
                {
                  key = "ctrl+j";
                  command = "-workbench.action.togglePanel";
                }
              ];
              userSettings = {
                "[nix]" = {
                  "editor.defaultFormatter" = "jnoortheen.nix-ide";
                  "editor.formatOnSave" = true;
                };
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
                "git.branchProtectionPrompt" = "alwaysCommit";
                "git.confirmSync" = false;
                "git.enableSmartCommit" = true;
                "git.replaceTagsWhenPull" = true;
                "github.copilot.chat.customOAIModels" = {
                  "Claude-Sonnet-4.5" = {
                    url = "https://api.poe.com/v1/";
                    name = "Claude-Sonnet-4.5";
                    requiresAPIKey = true;
                    toolCalling = true;
                    vision = true;
                    thinking = false;
                    maxInputTokens = 128000;
                    maxOutputTokens = 16000;
                  };
                };
                "makefile.configureOnOpen" = true;
                # nixd writes the buffer to the formatter, waitpid()s, then
                # reads stdout. nixfmt blocks on a full pipe, so format-on-save
                # hangs forever. nil drains stdout while the child runs.
                "nix.enableLanguageServer" = true;
                "nix.formatterPath" = [
                  (lib.getExe pkgs.nixfmt)
                  "-"
                ];
                "nix.serverPath" = lib.getExe pkgs.nil;
                "nix.serverSettings" = {
                  nil = {
                    formatting = {
                      command = [
                        (lib.getExe pkgs.nixfmt)
                        "-"
                      ];
                    };
                  };
                };
                "terminal.integrated.enableMultiLinePasteWarning" = "never";
                "terminal.integrated.scrollback" = 5000;
                "update.showReleaseNotes" = false;
                "window.titleBarStyle" = "custom";
                "workbench.colorTheme" = "Dark Modern";
                "workbench.secondarySideBar.defaultVisibility" = "hidden";
                "workbench.welcomePage.walkthroughs.openOnInstall" = false;
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
                dmenu = "${lib.getExe inputs'.pkgs.tofi} --prompt-text dunst";
                browser = "${lib.getExe' inputs'.pkgs.xdg-utils "xdg-open"}";
              };
            };
          };
          vscode-server.enable = true;
        };
        accounts.email.accounts = {
          "yt@radxa.com" =
            let
              # Home Manager hashes alias identities as sha256(address + realName).
              supportAlias = {
                realName = "ZHANG Yuntian";
                address = "yt@radxa.com";
              };
              supportId = builtins.hashString "sha256" (supportAlias.address + supportAlias.realName);
            in
            {
              realName = "ZHANG Yuntian";
              userName = "yt@radxa.com";
              address = "yt@radxa.com";
              aliases = [ supportAlias ];
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
                # settings is merged after identities, so this overrides the support identity only.
                settings = _: {
                  "mail.identity.id_${supportId}.identityName" = "ZHANG Yuntian";
                  "mail.identity.id_${supportId}.fcc" = false;
                  "mail.identity.id_${supportId}.reply_to" = "support@radxa.com";
                  "mail.identity.id_${supportId}.doCc" = true;
                  "mail.identity.id_${supportId}.doCcList" = "support@radxa.com";
                };
              };
            };
        };
      };
  };
}
