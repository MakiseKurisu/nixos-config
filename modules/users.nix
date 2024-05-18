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
        configFile = {
          "hypr" = {
            source = ../configs/hypr;
            recursive = true;
          };
          "waybar" = {
            source = ../configs/waybar;
            recursive = true;
          };
          "swayidle" = {
            source = ../configs/swayidle;
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
        kitty = {
          enable = true;
          settings = {
            confirm_os_window_close = 0;
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
          ];
        };
        vscode = {
          enable = true;
          enableExtensionUpdateCheck = false;
          enableUpdateCheck = false;
          package = pkgs.vscode.override (previous: {
            commandLineArgs = (previous.commandLineArgs or "") +
              " --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --enable-wayland-ime --password-store=gnome --disable-gpu-sandbox";
          });
          extensions = with pkgs.vscode-extensions; [
            bbenoist.nix
            github.vscode-github-actions
            github.vscode-pull-request-github
            ms-azuretools.vscode-docker
            ms-dotnettools.csharp
            ms-python.python
            ms-vscode.cmake-tools
            ms-vscode.cpptools
            ms-vscode.hexeditor
            ms-vscode.makefile-tools
            ms-vscode.powershell
            ms-vscode-remote.remote-ssh
            ms-vsliveshare.vsliveshare
            unifiedjs.vscode-mdx
          ];
          userSettings = {
            "editor.fontFamily" = "'Droid Sans Mono', 'monospace', monospace, 'NotoSans Nerd Font', 'Font Awesome 6 Free', 'RobotoMono Nerd Font'";
            "editor.selectionClipboard" = false;
            "git.autofetch" = true;
            "git.confirmSync" = false;
            "git.enableSmartCommit" = true;
            "editor.rulers" = [
              80
            ];
            "diffEditor.ignoreTrimWhitespace" = false;
            "debug.javascript.unmapMissingSources" = true;
            "editor.stickyScroll.enabled" = true;
            "files.autoGuessEncoding" = true;
            "files.autoSave" = "afterDelay";
            "window.titleBarStyle" = "custom";
          };
        };
      };
      services = {
        dunst = {
          enable = true;
          settings = {
            global = {
              monitor = "0";
            };
          };
        };
        vscode-server.enable = true;
      };
    };
  };
}
