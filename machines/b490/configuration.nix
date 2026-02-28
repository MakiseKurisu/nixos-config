{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ../../modules/zone/office.nix

    inputs.home-manager.nixosModules.home-manager
    ../../modules/base.nix
    ../../modules/desktop.nix
    # ../../modules/desktop-autostart.nix
    ../../modules/podman.nix
    # ../../modules/amd.nix
    ../../modules/intel.nix
    ../../modules/kernel.nix
    ../../modules/network.nix
    # ../../modules/nvidia.nix
    ../../modules/packages.nix
    ../../modules/users.nix
    # ../../modules/vfio.nix
    ../../modules/virtualization.nix
    ../../modules/impermanence.nix

    #../../modules/nfs-nas.nix
    #../../modules/nfs-app01.nix
    # ../../modules/wireguard.nix

    # ../../modules/thinkpad.nix

    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = lib.mkForce pkgs.unstable.linuxPackages_latest;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "i965";
  };

  hardware = {
    graphics = {
      extraPackages = with pkgs; [
        # OpenCL filter support on 12th gen or newer
        # intel-compute-runtime
        # OpenCL filter support up to 11th gen
        # see: https://github.com/NixOS/nixpkgs/issues/356535
        intel-compute-runtime-legacy1

        # VAAPI on 5th gen or newer. LIBVA_DRIVER_NAME=iHD
        # intel-media-driver
        # VAAPI up to 4th gen. LIBVA_DRIVER_NAME=i965
        intel-vaapi-driver

        # QSV on 11th gen or newer
        # vpl-gpu-rt
        # QSV up to 11th gen
        intel-media-sdk
      ];
    };
    nvidia = {
      prime = {
        # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
        intelBusId = "PCI:0@0:2:0";
        # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
        nvidiaBusId = "PCI:1@0:0:0";
      };
    };
  };

  networking.interfaces.enp4s0.useDHCP = false;
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
          LLDP = false;
          EmitLLDP = false;
          IPv6AcceptRA = false;
          IPv6SendRA = false;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "50-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          DHCP = true;
        };
        linkConfig = {
          RequiredForOnline = false;
        };
      };
    };
  };

  home-manager.users.excalibur =
    { pkgs, ... }:
    {
      home.stateVersion = "22.11";
      wayland.windowManager.hyprland = {
        settings = {
          exec-once = [
            "brightnessctl --device intel_backlight set 30%"
          ];
          workspace = [
            "r[1-20], monitor:LVDS-1"
            "2, monitor:LVDS-1, default:yes"
            "30, monitor:HDMI-A-1, default:yes"
          ];
        };
      };
    };

  networking.hostName = "b490";
  system.stateVersion = "25.05";
}
