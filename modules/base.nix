{ config, lib, pkgs, inputs, options, ... }:

{
  imports = [
    ./base-base.nix
  ];

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    rasdaemon.enable = true;
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
    settings = {
      substituters = lib.mkBefore [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirrors.sjtug.sjtu.edu.cn/nix-channels/store"
        "https://radxa.cachix.org"
      ];
      http2 = false;
    };
  };

  nixpkgs = {
    config = {
      permittedInsecurePackages = [
        "openssl-1.1.1w"
        "ventoy-1.1.07"
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

  services = {
    avahi = {
      enable = lib.mkDefault true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
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
}
