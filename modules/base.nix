{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.vgpu4nixos.nixosModules.host
  ];

  console = {
    earlySetup = true;
  };

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
  };

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
      ];
      trusted-users = [
        "root"
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
  powerManagement.powertop = {
    enable = lib.mkDefault true;
    postStart = ''
      ${lib.getExe' config.systemd.package "udevadm"} trigger -c bind -s usb -a idVendor=046d
    '';
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
    openssh.enable = true;
    qemuGuest.enable = true;
    xserver = {
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    smartd.enable = true;
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

  systemd.watchdog = {
    runtimeTime = "1m";
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
}
