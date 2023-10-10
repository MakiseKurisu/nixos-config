{ config, lib, pkgs, ... }:

{
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      ch9344
    ];
  };

  qt = {
    enable = true;
    platformTheme = "kde";
  };

  environment = {
    etc."greetd/environments".text = ''
      hyprland
      bash
    '';
    pathsToLink = [
      "/share/konsole"
    ];
    variables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_WEBRENDER = "1";
      MOZ_USE_XINPUT2 = "1";
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "hyprland";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_STYLE_OVERRIDE = "breeze";
      CLUTTER_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
    };
    sessionVariables = {
      EDITOR = "nano";
      VISUAL = "nano";
      BROWSER = "firefox";
      TERMINAL = "kitty";
    };
    systemPackages = with pkgs; [
      blueberry
      bottles
      brightnessctl
      discord
      dunst
      element-desktop-wayland
      firefox-wayland
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
      kicad
      libreoffice-qt
      libsForQt5.ark
      libsForQt5.breeze-gtk
      libsForQt5.breeze-icons
      libsForQt5.breeze-qt5
      libsForQt5.dolphin
      libsForQt5.kcalc
      libsForQt5.konsole
      lingot
      lutris
      mako
      mattermost-desktop
      moonlight-qt
      networkmanagerapplet
      nwg-bar
      nwg-menu
      nwg-dock
      nwg-panel
      nwg-drawer
      nwg-launchers
      pavucontrol
      pinentry-qt
      piper
      unstable.qq
      remmina
      rstudio
      skypeforlinux
      slack
      slurp
      solaar
      swayidle
      swaylock
      tdesktop
      unstable.teams-for-linux
      thunderbird
      ungoogled-chromium
      ventoy-bin-full
      vlc
      virt-viewer
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          bbenoist.nix
          ms-vscode-remote.remote-ssh
        ];
      })
      wev
      xdg-user-dirs
      xdg-utils
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
      ];
    };
  };

  security.pam.services.swaylock = {};

  programs = {
    dconf.enable = true;
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
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  services = {
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };
    dbus.enable = true;
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
    logind = {
      lidSwitch = "ignore";
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
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
    udisks2.enable = true;
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
