{ config, lib, pkgs, inputs, options, ... }:

{
  imports = [
    inputs.vgpu4nixos.nixosModules.host
  ];

  documentation.man.generateCaches = true;

  environment.enableAllTerminfo = true;

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    rasdaemon.enable = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
    extraLocales = [
      "ja_JP.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
  };

  networking.timeServers = options.networking.timeServers.default ++ [
    "ntp.ntsc.ac.cn"
    "cn.ntp.org.cn"
    "ntp1.nim.ac.cn"
    "ntp2.nim.ac.cn"
    "cn.pool.ntp.org"
    "ntp.aliyun.com"
    "ntp.tencent.com"
    "time.izatcloud.net"
    "time.gpsonextra.net"
    "hik-time.ys7.com"
    "time.ys7.com"
    "ntp.sjtu.edu.cn"
    "ntp.neu.edu.cn"
    "ntp.bupt.edu.cn"
    "ntp.shu.edu.cn"
    "ntp.tuna.tsinghua.edu.cn"
    "time.ustc.edu.cn"
    "ntp.fudan.edu.cn"
    "ntp.nju.edu.cn"
    "ntp.tongji.edu.cn"
    "stdtime.gov.hk"
    "time.smg.gov.mo"
  ];

  nix = {
    gc = {
      automatic = true;
      persistent = true;
      options = "--delete-older-than 7d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = lib.mkBefore [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirrors.sjtug.sjtu.edu.cn/nix-channels/store"
        "https://radxa.cachix.org"
      ];
      trusted-public-keys = [
        "radxa.cachix.org-1:Jc5T8fpq3URBLeKKHER2PxcuAd74iPMiW6TOb1M1yPc="
      ];
      trusted-users = [
        "@wheel"
      ];
      http2 = false;
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      packageOverrides = pkgs: {
        unstable = import inputs.nixpkgs-unstable {
          config = config.nixpkgs.config;
          system = pkgs.system;
          overlays = [
            pkgs.linuxPackages.nvidiaPackages.vgpuNixpkgsOverlay
          ];
        };
        master = import inputs.nixpkgs-master {
          config = config.nixpkgs.config;
          system = pkgs.system;
        };
        nur = import inputs.NUR {
          inherit pkgs;
          nurpkgs = pkgs;
        };
      };
      permittedInsecurePackages = [
        "electron-11.5.0"
        "ventoy-1.1.05"
        "openssl-1.1.1w"
      ];
    };
  };

  services.udev.extraRules = ''
    # disable USB auto suspend for Logitech, Inc. products
    ACTION=="bind", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", TEST=="power/control", ATTR{power/control}="on"
  '';
  powerManagement = {
    enable = true;
    powertop = {
      enable = lib.mkDefault true;
      postStart = ''
        ${lib.getExe' config.systemd.package "udevadm"} trigger -c bind -s usb -a idVendor=046d
      '';
    };
  };

  security = {
    sudo = {
      execWheelOnly = true;
      extraConfig = ''
        Defaults insults
        Defaults lecture = never
      '';
    };
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
      };
    };
    btrfs.autoScrub.enable = lib.mkDefault true;
    dbus.enable = true;
    irqbalance.enable = true;
    mysqlBackup.enable = config.services.mysql.enable;
    openssh.enable = true;
    postgresqlBackup.enable = config.services.postgresql.enable;
    resolved.enable = true;
    smartd.enable = true;
    xserver = {
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };

  system = {
    autoUpgrade = {
      enable = true;
      flags = [
        "--upgrade-all"
      ];
      flake = "github:MakiseKurisu/nixos-config";
      operation = "boot";
      randomizedDelaySec = "5min";
      dates = "*-*~01 08:00:00";
    };
  };

  systemd = {
    oomd.enableUserSlices = true;
    watchdog = {
      runtimeTime = "1m";
    };
  };

  zramSwap = {
    enable = lib.mkDefault true;
    algorithm = "zstd";
  };
}
