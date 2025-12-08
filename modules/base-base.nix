{ config, lib, pkgs, inputs, options, ... }:

{
  documentation.man.generateCaches = true;

  environment.enableAllTerminfo = true;

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

  nix = {
    optimise = {
      automatic = true;
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = lib.mkBefore [
        "https://radxa.cachix.org"
      ];
      trusted-public-keys = [
        "radxa.cachix.org-1:Jc5T8fpq3URBLeKKHER2PxcuAd74iPMiW6TOb1M1yPc="
      ];
      trusted-users = [
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
          system = pkgs.stdenv.hostPlatform.system;
        };
        master = import inputs.nixpkgs-master {
          config = config.nixpkgs.config;
          system = pkgs.stdenv.hostPlatform.system;
        };
        nur = import inputs.NUR {
          inherit pkgs;
          nurpkgs = pkgs;
        };
      };
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
    btrfs.autoScrub = {
      enable = lib.mkDefault true;
      interval = "Fri *-*~07/1 04:00:00";
    };
    dbus.enable = true;
    irqbalance.enable = true;
    mysqlBackup.enable = config.services.mysql.enable;
    openssh.enable = true;
    postgresqlBackup.enable = config.services.postgresql.enable;
    resolved.enable = true;
    xserver = {
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };

  systemd = {
    oomd.enableUserSlices = true;
    settings.Manager.RuntimeWatchdogSec = "1m";
  };

  zramSwap = {
    enable = lib.mkDefault true;
    algorithm = "zstd";
  };
}
