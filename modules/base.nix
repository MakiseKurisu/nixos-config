{ config, lib, pkgs, ... }:

{
  imports = [
    ./services.nix
  ];

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
    settings = {
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
      };
      permittedInsecurePackages = [
        "electron-24.8.6"
        "openssl-1.1.1w"
        "python3.10-cryptography-40.0.1"
        "python3.10-cryptography-40.0.2"
        "python3.10-requests-2.29.0"
      ];
    };
  };

  time.timeZone = "Asia/Shanghai";

  systemd = {
    enableUnifiedCgroupHierarchy = true;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
}
