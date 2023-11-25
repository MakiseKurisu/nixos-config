{ config, lib, pkgs, ... }:

{
  imports = [
    ./dolphin.nix
    ./plasma-systemsettings.nix
  ];

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      ch9344
    ];
  };

  environment = {
    etc."greetd/environments".text = ''
      hyprland
      bash
    '';
    variables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_WEBRENDER = "1";
      MOZ_USE_XINPUT2 = "1";
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "hyprland";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      CLUTTER_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
      XMODIFIERS = "@im=fcitx";
      QT_IM_MODULE = "fcitx";
      GTK_IM_MODULE = "fcitx";
    };
    sessionVariables = {
      EDITOR = "nano";
      VISUAL = "nano";
      BROWSER = "firefox";
      TERMINAL = "kitty";
    };
    systemPackages = with pkgs; [
      amtterm
      blueberry
      bottles
      brightnessctl
      cachix
      calibre
      (chromium.override (previous: {
        commandLineArgs = (previous.commandLineArgs or "") +
          " --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --enable-wayland-ime";
      }))
      (import <devenv>).default
      unstable.discord
      dunst
      element-desktop-wayland
      feishu
      font-manager
      fsearch
      freecad
      gimp
      github-desktop
      gnome3.adwaita-icon-theme
      greetd.wlgreet
      grim
      gsettings-desktop-schemas
      gtk3
      guvcview
      helvum
      hyprpaper
      imv
      jq
      kicad
      libreoffice-qt
      libsForQt5.ark
      libsForQt5.breeze-gtk
      libsForQt5.kcalc
      libwebp
      lingot
      lutris
      mako
      mattermost-desktop
      moonlight-qt
      networkmanagerapplet
      nixpkgs-review
      nss
      nwg-bar
      nwg-menu
      nwg-dock
      nwg-panel
      nwg-drawer
      nwg-launchers
      pavucontrol
      pinentry-qt
      piper
      pre-commit
      unstable.qq
      remmina
      rstudio
      unstable.skypeforlinux
      slack
      slurp
      solaar
      sunshine
      swayidle
      swaylock
      tdesktop
      unstable.teams-for-linux
      thunderbird
      ventoy-bin-full
      vlc
      virt-viewer
      (vscode-with-extensions.override (previous: {
        vscode = (previous.vscode.override (p: {
          commandLineArgs = (p.commandLineArgs or "") +
            " --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --enable-wayland-ime";
        }));
        vscodeExtensions = with vscode-extensions; [
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
      }))
      nur.repos.xddxdd.wechat-uos
      wev
      wsmancli
      xdg-utils
      yesplaymusic
    ];
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      cantarell-fonts
      twitter-color-emoji
      meslo-lgs-nf
      nerdfonts
      gentium
      source-code-pro
      source-sans-pro
      source-serif-pro
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      font-awesome
      wqy_zenhei
      wqy_microhei
    ];
    enableDefaultFonts = true;
    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        serif = [ "Source Serif Pro" "Noto Serif CJK SC" ];
        sansSerif = [ "Source Sans Pro" "Noto Sans CJK SC" ];
        monospace = [ "Source Code Pro" "Noto Sans Mono CJK SC" ];
      };
    };
  };

  i18n = {
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-gtk
        fcitx5-chinese-addons
        libsForQt5.fcitx5-qt
      ];
    };
  };

  security.pam.services.swaylock = {};

  programs = {
    adb.enable = true;
    /*
    # Conflict with starship
    # https://github.com/NixOS/nixpkgs/issues/257720
    # Waiting for https://github.com/starship/starship/commit/8168c21293de8118af1e95778b1eee8f26cd6d6a
    bash = {
      undistractMe = {
        enable = true;
        playSound = true;
        timeout = 45;
      };
    };
    */
    dconf.enable = true;
    direnv.enable = true;
    dolphin.enable = true;
    firefox = {
      enable = true;
      package = pkgs.firefox-wayland;
    };
    regreet.enable = true; 
    hyprland = {
      enable = true;
      xwayland.enable = true;
      #nvidiaPatches = true;
      package = pkgs.unstable.hyprland;
      #portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
    };
    waybar = {
      enable = true;
      package = pkgs.unstable.waybar;
    };
    starship = {
      enable = true;
      settings = {
        shlvl = {
          disabled = false;
          threshold = 1;
        };
        cmd_duration.show_notifications = true;
        status.disabled = false;
      };
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    system-config-printer.enable = true;
    wireshark.enable = true;
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
    sudo.execWheelOnly = true;
  };

  services = {
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };
    dbus.enable = true;
    fwupd.enable = true;
    greetd = {
      enable = true;
      settings = {
        default_session = let
          greetdConfig = pkgs.writeText "greetd-config" ''
              exec-once = ${pkgs.greetd.regreet}/bin/regreet; hyprctl dispatch exit
              animations {
                  enabled = off
              }
              misc {
                  force_hypr_chan = on
              }
            '';
        in {
          command = "${pkgs.unstable.hyprland}/bin/Hyprland --config ${greetdConfig} >/dev/null 2>/dev/null";
        };
      };
    };
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    locate.enable = true;
    logind = {
      lidSwitch = "ignore";
    };
    mpd = {
      enable = true;
      startWhenNeeded = true;
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        hplip
        epson-escpr
      ];
    };
    ratbagd.enable = true;
    rpcbind.enable = true; # needed for NFS
  };

  xdg = {
    portal = {
      enable = true;
      wlr.enable = true;
      # gtk portal needed to make firefox happy
      extraPortals = with pkgs; [ 
        xdg-desktop-portal-gtk
        #unstable.xdg-desktop-portal-hyprland
      ];
    };
    mime.defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
}
