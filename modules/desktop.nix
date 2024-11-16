{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./pr/dolphin.nix
    ./pr/mmdebstrap.nix
    ./plasma-systemsettings.nix
    ./hyprland.nix
    inputs.lix-module.nixosModules.default
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
      GTK_IM_MODULE = lib.mkForce "";
    };
    sessionVariables = {
      EDITOR = "nano";
      VISUAL = "nano";
      BROWSER = "firefox";
      TERMINAL = "kitty";
      NIX_AUTO_RUN = "1";
    };
    systemPackages = with pkgs; [
      amtterm
      audacity
      bottles
      brightnessctl
      cachix
      calibre
      (chromium.override (previous: {
        commandLineArgs = (previous.commandLineArgs or "") +
          " --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --enable-wayland-ime";
      }))
      cliphist
      colmena
      darktable
      devenv
      discord
      element-desktop
      element-desktop-wayland
      (feishu.override (previous: {
        commandLineArgs = (previous.commandLineArgs or "") +
          " --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=x11 --enable-wayland-ime";
      }))
      filezilla
      font-manager
      fsearch
      freecad
      gimp-with-plugins
      github-desktop
      ghidra
      ghidra-extensions.machinelearning
      ghidra-extensions.gnudisassembler
      gnome3.adwaita-icon-theme
      greetd.wlgreet
      grim
      gsettings-desktop-schemas
      gtk3
      guvcview
      helvum
      hyprpaper
      jq
      kicad
      krita
      libreoffice-qt
      kdePackages.ark
      kdePackages.breeze-gtk
      kdePackages.kcalc
      kdePackages.qtwayland
      libwebp
      lingot
      lmms
      lutris
      mako
      mattermost-desktop
      pr-mmdebstrap.mmdebstrap
      mob
      moonlight-qt
      musescore
      networkmanagerapplet
      nixpkgs-review
      nomacs
      nss
      nuclear
      nwg-bar
      nwg-menu
      nwg-dock
      nwg-panel
      nwg-drawer
      nwg-launchers
      opentofu
      pinentry-qt
      piper
      pre-commit
      pwvucontrol
      qq
      qrencode
      remmina
      rs-tftpd
      rstudio
      selectdefaultapplication
      skypeforlinux
      slack
      slurp
      solaar
      sops
      sunshine
      sweethome3d.application
      tdesktop
      teams-for-linux
      thunderbird
      ventoy-full
      vlc
      virt-viewer
      nur.repos.xddxdd.wechat-uos
      wev
      wlr-randr
      wireguard-tools
      wofi
      wsmancli
      xdg-utils
      yarn
    ];
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
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
    enableDefaultPackages = true;
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
        kdePackages.fcitx5-qt
      ];
    };
  };

  programs = {
    adb.enable = true;
    apt = {
      enable = true;
      package = pkgs.pr-mmdebstrap.apt;
      keyringPackages = with pkgs; [
        pr-mmdebstrap.debian-archive-keyring
      ];
    };
    dconf.enable = true;
    dolphin.enable = true;
    firefox = {
      enable = true;
      package = pkgs.firefox-wayland;
    };
    regreet.enable = true;
    hyprland.enable = true;
    hyprlock.enable = true;
    waybar = {
      enable = true;
      package = pkgs.waybar;
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
  };

  services = {
    ananicy.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = true;
    };
    blueman.enable = true;
    dbus.enable = true;
    envfs.enable = true;
    fwupd.enable = true;
    greetd = {
      enable = true;
      settings = {
        default_session =
          let
            greetdConfig = pkgs.writeText "greetd-config" ''
              exec-once = ${pkgs.greetd.regreet}/bin/regreet; hyprctl dispatch exit
              animations {
                  enabled = off
              }
              misc {
                  force_default_wallpaper = 2
              }
            '';
          in
          {
            command = "${pkgs.hyprland}/bin/Hyprland --config ${greetdConfig} >/dev/null 2>/dev/null";
          };
      };
    };
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    hypridle.enable = true;
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

  hardware.bluetooth.enable = true;

  xdg = {
    portal = {
      enable = true;
      # xdg-open is broken and cannot open link from discord
      # xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
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
