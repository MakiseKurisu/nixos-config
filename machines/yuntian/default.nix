{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/podman.nix
    ../../modules/intel.nix
    ../../modules/kernel.nix
    ../../modules/network.nix
    # ../../modules/nvidia.nix
    ../../modules/packages.nix
    ../../modules/users.nix
    ../../modules/vfio.nix
    ../../modules/virtualization.nix

    # ../../modules/nfs-nas.nix
    # ../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    inputs.disko.nixosModules.disko
    # ./disko.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = lib.mkForce pkgs.unstable.linuxPackages_latest;

  home-manager.users.excalibur = { pkgs, ... }: {
    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "${pkgs.xorg.xrdb}/bin/xrdb -merge <${pkgs.writeText "Xresources" ''
          Xft.dpi: 144
        ''}"
      ];
      xwayland = {
        force_zero_scaling = true;
      };
    };
    xdg.configFile = {
      "hypr/machine.conf" = {
        source = pkgs.writeText "hyprland-machine.conf" ''
          monitor=DP-1, highres, 0x0, 1.5, vrr, 0
          monitor=HDMI-A-2, highres, auto-right, 1.5
          workspace=2, monitor:DP-1, default:yes
          workspace=30, monitor:HDMI-A-2, default:yes
        '';
      };
    };
  };

  powerManagement.powertop.enable = false;

  programs = {
    git = {
      config = {
        credential = {
          "https://github.com".username = "RadxaYuntian";
        };
        user = {
          name = "ZHANG Yuntian";
          email = "yt@radxa.com";
        };
      };
    };
  };

  networking.interfaces.enp4s0.useDHCP = false;
  # enable WoL causes interface to be configured with DHCP
  # networking.interfaces.enp4s0.wakeOnLan.enable = true;
  systemd.network = {
    netdevs = {
      "20-br0" = {
         netdevConfig = {
           Kind = "bridge";
           Name = "br0";
         };
        bridgeConfig = {
          STP = true;
          VLANFiltering = true;
        };
      };
    };
    networks = {
      "30-enp4s0" = {
        matchConfig.Name = "enp4s0";
        networkConfig = {
          Bridge = "br0";
          LinkLocalAddressing = false;
          DHCP = false;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "50-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          DHCP = true;
          Domains = "vamrs.org protoducer.com";
          Address = "192.168.2.20/24";
        };
        linkConfig = {
          RequiredForOnline = false;
        };
      };
    };
  };

  networking.hostName = "yuntian";
  system.stateVersion = "25.05";
}
