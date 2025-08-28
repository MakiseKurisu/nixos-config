{ config, lib, pkgs, inputs, options, ... }:

{
  imports = [
    ./pr/mmdebstrap.nix
    ./hyprland.nix
    ./waybar.nix
    inputs.lix-module.nixosModules.default
    inputs.aagl.nixosModules.default
    inputs.nixified-ai.nixosModules.comfyui
  ];

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      ch9344
    ];
    binfmt = {
      preferStaticEmulators = true;
      emulatedSystems = [
        "aarch64-linux"
        "riscv64-linux"
        "x86_64-windows"
        "i686-windows"
      ];
    };
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
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      CLUTTER_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
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
      dbeaver-bin
      pkgs.unstable.devenv
      discord
      element-desktop
      (feishu.override (previous: {
        commandLineArgs = (previous.commandLineArgs or "") +
          " --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=x11 --enable-wayland-ime";
      }))
      file-roller
      filezilla
      font-manager
      fsearch
      freecad
      gimp-with-plugins
      ghidra
      ghidra-extensions.machinelearning
      ghidra-extensions.gnudisassembler
      gnome-calculator
      greetd.wlgreet
      grim
      gsettings-desktop-schemas
      gtk3
      guvcview
      helvum
      hyprcursor
      jq
      kicad
      krita
      libreoffice-qt
      kdePackages.qtwayland
      libwebp
      lingot
      lmms
      mako
      mattermost-desktop
      pr-mmdebstrap.mmdebstrap
      mob
      moonlight-qt
      musescore
      muse-sounds-manager
      nautilus
      networkmanagerapplet
      nixpkgs-review
      nomacs
      nss
      nwg-bar
      nwg-menu
      nwg-look
      nwg-panel
      nwg-hello
      nwg-drawer
      nwg-displays
      nwg-launchers
      nwg-dock-hyprland
      openscad-unstable
      (opentofu.withPlugins (p: with p; [
        cloudflare
        github
        incus
        oci
        sops
      ]))
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
      shotcut
      slack
      slurp
      solaar
      sops
      sweethome3d.application
      tdesktop
      teams-for-linux
      ventoy-full
      vlc
      wechat-uos
      wemeet
      wev
      wlr-randr
      wireguard-tools
      wofi
      wsmancli
      xdg-utils
      xxd
      yarn
    ];
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      cantarell-fonts
      twitter-color-emoji
      meslo-lgs-nf
      gentium
      source-code-pro
      source-sans-pro
      source-serif-pro
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts-emoji-blob-bin
      noto-fonts-monochrome-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      font-awesome
      wqy_zenhei
      wqy_microhei
    ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
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
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-chinese-addons
          kdePackages.fcitx5-qt
        ];
      };
    };
  };

  nix.settings = inputs.aagl.nixConfig;
  programs = {
    anime-game-launcher.enable = true;
    anime-games-launcher.enable = true;
    honkers-railway-launcher.enable = true;
    honkers-launcher.enable = true;
    wavey-launcher.enable = true;
    sleepy-launcher.enable = true;

    adb.enable = true;
    apt = {
      enable = true;
      package = pkgs.pr-mmdebstrap.apt;
      keyringPackages = with pkgs; [
        pr-mmdebstrap.debian-archive-keyring
      ];
    };
    dconf.enable = true;
    firefox = {
      enable = true;
      package = pkgs.firefox-wayland;
    };
    gamemode = {
      enable = true;
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    regreet.enable = true;
    hyprland.enable = true;
    seahorse.enable = true;
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
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      extest.enable = true;
      extraPackages = with pkgs; [
        mangohud
        gamescope
        gamemode
      ];
      extraCompatPackages = [ pkgs.unstable.proton-ge-bin ];
      protontricks.enable = true;
    };
    system-config-printer.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
    pam.services.greetd.enableGnomeKeyring = true;
  };

  services = {
    ananicy.enable = true;
    aria2 = {
      enable = true;
      rpcSecretFile = pkgs.writeText "aria2-rpc-token.txt" "P3TERX";
    };
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
        default_session.command =
          let
            greetdConfig = pkgs.writeText "greetd-config" ''
              exec-once = ${lib.getExe config.programs.regreet.package}; hyprctl dispatch exit
              animations {
                  enabled = off
              }
              misc {
                  force_default_wallpaper = 2
              }
            '';
          in
            "${lib.getExe' pkgs.dbus "dbus-run-session"} ${lib.getExe pkgs.hyprland} --config ${greetdConfig}";
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
    sunshine = {
      enable = true;
      capSysAdmin = true;
      openFirewall = true;
    };
    systemd-lock-handler.enable = true;
  };

  hardware = {
    graphics = {
      enable = true;
    };
    bluetooth.enable = true;
  };

  home-manager = {
    users.excalibur = { lib, pkgs, osConfig, ... }: {
      services = {
        easyeffects.enable = true;
      };
      programs = {
        lutris = {
          enable = true;
          winePackages = [ 
            pkgs.unstable.wineWowPackages.full
            pkgs.unstable.wineWow64Packages.full
          ];
          protonPackages = [ pkgs.unstable.proton-ge-bin ];
          steamPackage = osConfig.programs.steam.package;
          extraPackages = with pkgs; [
            mangohud
            winetricks
            gamescope
            gamemode
            umu-launcher
          ];
        };
      };
      home.pointerCursor = {
        enable = true;
        name = "phinger-cursors-light";
        package = pkgs.phinger-cursors;
      };
      xdg = {
        portal = {
          enable = true;
          xdgOpenUsePortal = true;
          config = {
            common = {
              default = [
                "hyprland"
                "gtk"
              ];
            };
          };
          extraPortals = [
            pkgs.xdg-desktop-portal-hyprland
            pkgs.xdg-desktop-portal-gtk
          ];
        };
        mime.enable = true;
        mimeApps = {
          enable = true;
          associations.added = {
            "application/x-shellscript" = [ "code.desktop" ];
          };
          defaultApplications = {
            # find /run/current-system/sw/share/applications/ -name "**"
            # More folders are available under $XDG_DATA_DIRS
            "image/bmp" = [ "org.nomacs.ImageLounge.desktop" ];
            "image/gif" = [ "org.nomacs.ImageLounge.desktop" ];
            "image/jpeg" = [ "org.nomacs.ImageLounge.desktop" ];
            "image/png" = [ "org.nomacs.ImageLounge.desktop" ];
            "image/svg+xml" = [ "org.nomacs.ImageLounge.desktop" ];
            "image/webp" = [ "org.nomacs.ImageLounge.desktop" ];
            "text/html" = [ "firefox.desktop" ];
            "x-scheme-handler/about" = [ "firefox.desktop" ];
            "x-scheme-handler/http" = [ "firefox.desktop" ];
            "x-scheme-handler/https" = [ "firefox.desktop" ];
            "x-scheme-handler/unknown" = [ "firefox.desktop" ];
            "x-scheme-handler/baiduyunguanjia" = [ "baidunetdisk.desktop" ];
            "x-scheme-handler/msteams" = [ "teams-for-linux.desktop" ];
            "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
            "x-scheme-handler/mid" = [ "thunderbird.desktop" ];
            "x-scheme-handler/news" = [ "thunderbird.desktop" ];
            "x-scheme-handler/snews" = [ "thunderbird.desktop" ];
            "x-scheme-handler/nntp" = [ "thunderbird.desktop" ];
            "x-scheme-handler/feed" = [ "thunderbird.desktop" ];
            "application/rss+xml" = [ "thunderbird.desktop" ];
            "application/x-extension-rss" = [ "thunderbird.desktop" ];
            "x-scheme-handler/webcal" = [ "thunderbird.desktop" ];
            "x-scheme-handler/webcals" = [ "thunderbird.desktop" ];
            "message/rfc822" = [ "thunderbird.desktop" ];
            "text/calendar" = [ "thunderbird.desktop" ];
            "application/x-extension-ics" = [ "thunderbird.desktop" ];
            "model/step" = [ "org.freecad.FreeCAD.desktop" ];
            "text/plain" = [ "code.desktop" ];
            "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
            "application/pdf" = [ "chromium-browser.desktop" ];
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
            "video/mp4" = [ "vlc.desktop" ];
            "video/x-matroska" = [ "vlc.desktop" ];
          };
        };
      };
    };
  };
}
