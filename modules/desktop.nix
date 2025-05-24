{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./pr/mmdebstrap.nix
    ./plasma-systemsettings.nix
    ./hyprland.nix
    inputs.lix-module.nixosModules.default
    inputs.aagl.nixosModules.default
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
      QT_QPA_PLATFORM = "wayland";
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
      devenv
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
      github-desktop
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
      lutris
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
      nuclear
      nwg-bar
      nwg-menu
      nwg-look
      nwg-panel
      nwg-hello
      nwg-drawer
      nwg-displays
      nwg-launchers
      nwg-dock-hyprland
      (opentofu.withPlugins (p: with p; [
        incus
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
      wechat-uos
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
    alvr = {
      enable = true;
      openFirewall = true;
    };
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
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      extest.enable = true;
      extraPackages = [ pkgs.gamescope ];
      extraCompatPackages = [ pkgs.proton-ge-bin ];
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
    greetd.enable = true;
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

  home-manager = {
    users.excalibur = { pkgs, ... }: {
      services = {
        easyeffects.enable = true;
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
          defaultApplications = {
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
          };
        };
      };
    };
  };
}
