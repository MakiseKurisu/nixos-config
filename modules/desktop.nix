{ config, lib, pkgs, inputs, options, ... }:

{
  imports = [
    ./pr/mmdebstrap.nix
    ./hyprland.nix
    ./waybar.nix
    inputs.nixified-ai.nixosModules.comfyui
  ];

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      ch9344
    ];
    binfmt = {
      preferStaticEmulators = true;
      emulatedSystems = [
        (lib.mkIf (pkgs.stdenv.hostPlatform.system != "aarch64-linux") "aarch64-linux")
        (lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") "riscv64-linux")
        (lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") "x86_64-windows")
        (lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") "i686-windows")
      ];
    };
  };

  environment = {
    etc = {
      "greetd/environments".text = ''
        hyprland
        bash
      '';
      # https://discourse.nixos.org/t/hyprland-dolphin-file-manager-trying-to-open-an-image-asks-for-a-program-to-use-for-open-it/69824/3
      # https://github.com/NixOS/nixpkgs/issues/409986
      # Run `rm -rf ~/.cache/ksyscoca* && kbuildsycoca6`
      "xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
    };
    variables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_WEBRENDER = "1";
      MOZ_USE_XINPUT2 = "1";
      XDG_SESSION_TYPE = "wayland";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      CLUTTER_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland,x11,windows";
      DXVK_CONFIG = "dxgi.customDeviceDesc = 'AMD Radeon Graphics (RADV VANGOGH)'";
    };
    sessionVariables = {
      EDITOR = "nano";
      VISUAL = "nano";
      BROWSER = "firefox";
      TERMINAL = "kitty";
      NIX_AUTO_RUN = "1";
    };
    systemPackages = with pkgs; [
      audacity
      nur.repos.xddxdd.baidunetdisk
      (bottles.override (previous: {
        removeWarningPopup = true;
      }))
      brightnessctl
      cachix
      calibre
      (unstable.chromium.override (previous: {
        commandLineArgs = (previous.commandLineArgs or "") +
          " --ozone-platform-hint=auto --enable-features=UseOzonePlatform,WaylandWindowDecorations,TouchpadOverscrollHistoryNavigation --gtk-version=4 --enable-features=WaylandPerSurfaceScale,WaylandUiScale --enable-wayland-ime --wayland-text-input-version=3";
      }))
      cliphist
      darktable
      dbeaver-bin
      deploy-rs
      pkgs.unstable.devenv
      (nur.repos.xddxdd.dingtalk.overrideAttrs (previous: {
        postFixup = (previous.postFixup or "") + ''
          echo "9.9.99-Release.9999999" > $out/version
        '';
      }))
      discord
      element-desktop
      (feishu.override (previous: {
        commandLineArgs = (previous.commandLineArgs or "") +
          " --ozone-platform-hint=auto --enable-features=UseOzonePlatform,WaylandWindowDecorations,TouchpadOverscrollHistoryNavigation --gtk-version=4 --enable-features=WaylandPerSurfaceScale,WaylandUiScale --enable-wayland-ime --wayland-text-input-version=3";
      }))
      filezilla
      flashrom
      font-manager
      fsearch
      freecad
      gimp-with-plugins
      ghidra
      ghidra-extensions.machinelearning
      ghidra-extensions.gnudisassembler
      wlgreet
      grim
      gsettings-desktop-schemas
      gtk3
      guvcview
      helvum
      (lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") heroic)
      hyprcursor
      jq
      kicad
      krita
      libreoffice-qt
      kdePackages.ark
      kdePackages.baloo-widgets
      kdePackages.breeze
      kdePackages.breeze-icons
      kdePackages.breeze-gtk
      kdePackages.dolphin
      kdePackages.dolphin-plugins
      kdePackages.kcalc
      kdePackages.kdegraphics-thumbnailers
      kdePackages.kio
      kdePackages.kio-admin
      kdePackages.kio-extras
      kdePackages.kio-fuse
      kdePackages.konsole
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
      naps2
      networkmanagerapplet
      nixfmt
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
      (lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") openscad-unstable)
      (opentofu.withPlugins (p: with p; [
        cloudflare_cloudflare
        integrations_github
        lxc_incus
        oracle_oci
        carlpett_sops
      ]))
      pinentry-qt
      piper
      pre-commit
      pkgs.unstable.protonplus
      pwvucontrol
      qq
      qrencode
      remmina
      rs-tftpd
      rstudio
      sc-controller
      selectdefaultapplication
      shotcut
      (lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") slack)
      slurp
      solaar
      sops
      sweethome3d.application
      telegram-desktop
      teams-for-linux
      ventoy-full
      vlc
      wechat
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
    enableGhostscriptFonts = true;
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

  hardware = {
    sane = {
      enable = true;
      extraBackends = with pkgs; [
        (lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux")
          (epsonscan2.override {
            withNonFreePlugins = true;
        }))
        hplipWithPlugin
        sane-airscan
      ];
    };
  };

  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; with qt6Packages; [
          fcitx5-gtk
          fcitx5-chinese-addons
          fcitx5-qt
        ];
      };
    };
  };

  nix = {
    package = pkgs.lixPackageSets.stable.lix;
  };

  nixpkgs.overlays = [
    (final: prev: {
      inherit (inputs.nixpkgs.legacyPackages.x86_64-linux.pkgs.lixPackageSets.stable);
    })
  ];

  programs = {
    adb.enable = true;
    apt = {
      enable = true;
      package = pkgs.pr-mmdebstrap.apt;
      keyringPackages = with pkgs; [
        pr-mmdebstrap.debian-archive-keyring
      ];
    };
    bash.blesh.enable = true;
    dconf.enable = true;
    firefox.enable = true;
    gamemode = {
      enable = true;
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    gnupg.agent = {
      pinentryPackage = pkgs.pinentry-gtk2;
    };
    regreet.enable = true;
    hyprland.enable = true;
    seahorse.enable = true;
    steam = {
      enable = (pkgs.stdenv.hostPlatform.system == "x86_64-linux");
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
    pam.services = {
      greetd.enableGnomeKeyring = true;
      greetd-password.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
    };
  };

  services = {
    ananicy.enable = true;
    aria2 = {
      enable = true;
      rpcSecretFile = pkgs.writeText "aria2-rpc-token.txt" "P3TERX";
    };
    blueman.enable = true;
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
              $mainMod=SUPER
              bind=$mainMod, M, exit,
              env=GSK_RENDERER,ngl
              monitor=VGA-1,disable
              monitor=HDMI-A-2,disable
            '';
          in
            "${lib.getExe' pkgs.dbus "dbus-run-session"} ${lib.getExe pkgs.hyprland} --config ${greetdConfig}";
      };
    };
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    hypridle.enable = true;
    locate.enable = true;
    logind.settings.Login.HandleLidSwitch = "ignore";
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
        hplipWithPlugin
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
    udisks2.enable = true;
    udev.extraRules = ''
      ACTION=="change" KERNEL=="card*", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", DRIVERS=="i915", SYMLINK+="dri/card-intel"
      ACTION=="change" KERNEL=="card*", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", DRIVERS=="amdgpu", SYMLINK+="dri/card-amd"
      ACTION=="change" KERNEL=="card*", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", DRIVERS=="nvidia", SYMLINK+="dri/card-nvidia"
      ACTION=="change" KERNEL=="card*", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", DRIVERS=="nouveau", SYMLINK+="dri/card-nvidia"
      ACTION=="change" KERNEL=="card*", SUBSYSTEM=="drm", SUBSYSTEMS=="platform", DRIVERS=="panthor", SYMLINK+="dri/card-mali"
    '';
  };

  hardware = {
    graphics = {
      enable = true;
    };
  };

  home-manager = {
    users.excalibur = { lib, pkgs, osConfig, ... }: {
      services = {
        arrpc.enable = true;
        easyeffects.enable = true;
      };
      programs = {
        lutris = {
          enable = (pkgs.stdenv.hostPlatform.system == "x86_64-linux");
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
            pkgs.kdePackages.xdg-desktop-portal-kde
          ];
        };
        mime.enable = true;
        mimeApps = {
          enable = true;
          associations.added = {
            "application/json" = [ "code.desktop" ];
            "application/x-shellscript" = [ "code.desktop" ];
            "video/mpeg" = [ "vlc.desktop" ];
          };
          defaultApplications = {
            # find /run/current-system/sw/share/applications/ -name "**"
            # More folders are available under $XDG_DATA_DIRS
            "application/json" = [ "code.desktop" ];
            "application/pdf" = [ "chromium-browser.desktop" ];
            "application/rss+xml" = [ "thunderbird.desktop" ];
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
            "application/x-extension-ics" = [ "thunderbird.desktop" ];
            "application/x-extension-rss" = [ "thunderbird.desktop" ];
            "image/bmp" = [ "org.nomacs.ImageLounge.desktop" ];
            "image/gif" = [ "org.nomacs.ImageLounge.desktop" ];
            "image/jpeg" = [ "org.nomacs.ImageLounge.desktop" ];
            "image/png" = [ "org.nomacs.ImageLounge.desktop" ];
            "image/svg+xml" = [ "org.nomacs.ImageLounge.desktop" ];
            "image/webp" = [ "org.nomacs.ImageLounge.desktop" ];
            "inode/directory" = [ "org.kde.dolphin" ];
            "message/rfc822" = [ "thunderbird.desktop" ];
            "model/step" = [ "org.freecad.FreeCAD.desktop" ];
            "text/calendar" = [ "thunderbird.desktop" ];
            "text/html" = [ "firefox.desktop" ];
            "text/plain" = [ "code.desktop" ];
            "video/mp4" = [ "vlc.desktop" ];
            "video/mpeg" = [ "vlc.desktop" ];
            "video/x-matroska" = [ "vlc.desktop" ];
            "x-scheme-handler/about" = [ "firefox.desktop" ];
            "x-scheme-handler/baiduyunguanjia" = [ "baidunetdisk.desktop" ];
            "x-scheme-handler/feed" = [ "thunderbird.desktop" ];
            "x-scheme-handler/http" = [ "firefox.desktop" ];
            "x-scheme-handler/https" = [ "firefox.desktop" ];
            "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
            "x-scheme-handler/mid" = [ "thunderbird.desktop" ];
            "x-scheme-handler/msteams" = [ "teams-for-linux.desktop" ];
            "x-scheme-handler/news" = [ "thunderbird.desktop" ];
            "x-scheme-handler/nntp" = [ "thunderbird.desktop" ];
            "x-scheme-handler/snews" = [ "thunderbird.desktop" ];
            "x-scheme-handler/unknown" = [ "firefox.desktop" ];
            "x-scheme-handler/webcal" = [ "thunderbird.desktop" ];
            "x-scheme-handler/webcals" = [ "thunderbird.desktop" ];
          };
        };
      };
    };
  };
}
