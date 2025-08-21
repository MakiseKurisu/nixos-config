{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/base.nix
    ../../modules/file-share.nix
    #../../modules/desktop.nix
    ../../modules/podman.nix
    ../../modules/intel-base.nix
    ../../modules/kernel.nix
    ../../modules/network.nix
    #../../modules/nvidia.nix
    ../../modules/packages-base.nix
    ../../modules/users-base.nix
    #../../modules/vfio.nix
    ../../modules/virtualization-base.nix
    ../../modules/impermanence.nix
    ../../modules/wwan.nix

    #../../modules/nfs-nas.nix
    # ../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    # ../../modules/pr/fastapi-dls.nix
    # ../../modules/pr/pico-rpa.nix

    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot = {
    kernelModules = [
      "iptable_mangle"
      "ip6table_mangle"
    ];
    extraModulePackages = with config.boot.kernelPackages; [ r8125 ];
    blacklistedKernelModules = [ "r8169" ];
  };

  services = {
    thermald.enable = false;  # Disable on older Intel systems
  };

  systemd.services = {
    e1000e = {
      script = ''
        set -eu
        ${lib.getExe pkgs.ethtool} -K eno1 tso off
      '';
      serviceConfig = {
        Type = "oneshot";
      };
      wantedBy = [ "sys-subsystem-net-devices-eno1.device" ];
    };
  };

  networking.interfaces.eno1.useDHCP = false;
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
      "30-eno1" = {
        matchConfig.Name = "eno1";
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "enslaved";
        bridgeVLANs = [
          {
            PVID = 1;
            EgressUntagged = 1;
          }
          {
            VLAN = 10;
          }
          {
            VLAN = 20;
          }
          {
            VLAN = 30;
          }
        ];
      };
      "40-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          LinkLocalAddressing = false;
        };
        bridgeConfig = {};
        bridgeVLANs = [
          {
            PVID = 1;
            EgressUntagged = 1;
          }
          {
            VLAN = 10;
          }
          {
            VLAN = 20;
          }
          {
            VLAN = 30;
          }
        ];
        vlan = [
          "vlan20"
        ];
        linkConfig = {
          RequiredForOnline = false;
        };
      };
      "50-vlan20" = {
        matchConfig.Name = "vlan20";
        networkConfig = {
          DHCP = true;
          Domains = "protoducer.com vamrs.org";
          Address = "192.168.9.2/24";
        };
        linkConfig = {
          RequiredForOnline = false;
        };
      };
    };
  };

  networking.hostName = "app01";
  system.stateVersion = "25.05";
  home-manager.users.excalibur.home.stateVersion = "22.11";
}
