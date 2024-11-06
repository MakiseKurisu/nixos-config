{ config, lib, pkgs, inputs, ... }:

{
  imports = [
  ];

  console = {
    earlySetup = true;
  };

  documentation.man.generateCaches = true;

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
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
      experimental-features = "nix-command flakes";
      substituters = lib.mkBefore [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
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
      ];
    };
  };

  powerManagement.powertop.enable = true;

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
    enableUnifiedCgroupHierarchy = true;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
}
