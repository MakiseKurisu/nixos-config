{ config, lib, pkgs, ... }:

{
  imports = [
    ./services.nix
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
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
      substituters = lib.mkBefore [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      ];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      packageOverrides = pkgs: {
        unstable = import <nixos-unstable> {
          config = config.nixpkgs.config;
        };
        nur = import <nur> {
          inherit pkgs;
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
    layout = "us";
    xkbVariant = "";
  };

  system = {
    autoUpgrade ={
      enable = true;
      persistent = true;
      operation = "boot";
      flags = [
        "--upgrade-all"
      ];
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
