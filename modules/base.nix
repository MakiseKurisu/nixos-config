{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./services.nix
    inputs.lix-module.nixosModules.default
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
        "electron-19.1.9"
        "electron-24.8.6"
        "openssl-1.1.1w"
        "python3.10-cryptography-40.0.1"
        "python3.10-cryptography-40.0.2"
        "python3.10-requests-2.29.0"
      ];
    };
  };

  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
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
      persistent = true;
      randomizedDelaySec = "30min";
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
