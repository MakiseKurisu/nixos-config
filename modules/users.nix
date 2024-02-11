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
          "kitty" = {
            source = ../configs/kitty;
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
              " --enable-features=UseOzonePlatform,WaylandWindowDecorations --password-store=gnome --ozone-platform=wayland --disable-gpu-sandbox --enable-wayland-ime";
          });
          extensions = with pkgs.vscode-extensions; [
            bbenoist.nix
            github.vscode-github-actions
            github.vscode-pull-request-github
            ms-vscode-remote.remote-ssh
            ms-dotnettools.csharp
            ms-vscode.cpptools
            ms-vsliveshare.vsliveshare
            ms-python.python
            ms-vscode.hexeditor
            ms-vscode.powershell
            ms-vscode.cmake-tools
            ms-vscode.makefile-tools
            ms-azuretools.vscode-docker
          ];
          userSettings = {
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
            "files.autoSave" = "afterDelay";
            "window.titleBarStyle" = "custom";
          };
        };
      };
      services.vscode-server.enable = true;
    };
  };
}
