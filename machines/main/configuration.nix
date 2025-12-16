{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/zone/home.nix

    inputs.home-manager.nixosModules.home-manager
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/desktop-autostart.nix
    ../../modules/podman.nix
    ../../modules/amd.nix
    #../../modules/intel.nix
    ../../modules/kernel.nix
    ../../modules/network.nix
    ../../modules/nvidia.nix
    ../../modules/packages.nix
    ../../modules/users.nix
    ../../modules/vfio.nix
    ../../modules/virtualization.nix
    ../../modules/vr.nix

    ../../modules/nfs-nas.nix
    # ../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = lib.mkForce pkgs.unstable.linuxPackages_latest;
    kernelModules = [
      "nct6775"
      "ntsync"
    ];
  };

  home-manager.users.excalibur = { pkgs, ... }: {
    home.stateVersion = "22.11";
    wayland.windowManager.hyprland.settings = {
      workspace = [
        "r[1-20], monitor:DP-2"
        "2, monitor:DP-2, default:yes"
        "30, monitor:DP-3, default:yes"
      ];
    };
  };

  hardware = {
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      prime = {
        amdgpuBusId = "PCI:15@0:0:0";
        nvidiaBusId = "PCI:14@0:0:0";
      };
    };
  };

  power.ups = {
    enable = true;
    mode = "netclient";
    upsmon = {
      monitor = {
        SMT1500I = {
          passwordFile = "${pkgs.writeText "ups-guest.txt" "guest"}";
          system = "SMT1500I@192.168.9.3";
          type = "secondary";
          user = "guest";
        };
      };
    };
  };

  networking.interfaces.enp10s0.useDHCP = false;
  networking.interfaces.enp13s0.useDHCP = false;
  networking.interfaces.enp13s0.wakeOnLan.enable = true;
  networking.interfaces.eth10.useDHCP = false;
  systemd.network = {
    links = {
      "40-eth10" = {
        matchConfig = {
          OriginalName = lib.mkForce "e*";
          MACAddress = "f8:e4:3b:38:c6:8c";
        };
        linkConfig = {
          Name = "eth10";
        };
      };
    };
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
      "30-enp10s0" = {
        matchConfig.Name = "enp10s0";
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
          {
            VLAN = 40;
          }
        ];
      };
      "30-enp13s0" = {
        matchConfig.Name = "enp13s0";
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
          {
            VLAN = 40;
          }
        ];
      };
      "30-eth10" = {
        matchConfig.Name = "eth10";
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "no";
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
          {
            VLAN = 40;
          }
        ];
      };
      "30-vnet" = {
        matchConfig.Name = "vnet*";
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "enslaved";
        bridgeVLANs = [
          {
            PVID = 20;
            EgressUntagged = 20;
          }
        ];
      };
      "40-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          LinkLocalAddressing = false;
          DHCP = false;
          LLDP = false;
          EmitLLDP = false;
          IPv6AcceptRA = false;
          IPv6SendRA = false;
        };
        bridgeConfig = {
          HairPin = true;
        };
        bridgeVLANs = [
          {
            VLAN = 1;
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
          {
            VLAN = 40;
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
          Address = "192.168.9.20/24";
        };
        linkConfig = {
          RequiredForOnline = false;
        };
      };
    };
  };

  networking.hostName = "main";
  system.stateVersion = "24.11";
}
