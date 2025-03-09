{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/podman.nix
    #../../modules/intel.nix
    ../../modules/kernel.nix
    ../../modules/network.nix
    # ../../modules/nvidia.nix
    ../../modules/packages.nix
    ../../modules/users.nix
    ../../modules/vfio.nix
    ../../modules/virtualization.nix

    ../../modules/nfs-nas.nix
    # ../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    ./hardware-configuration.nix
  ];

  boot = {
    kernelParams = [
      "console=ttyS0"
    ];
    loader.efi.efiSysMountPoint = "/boot/efi";
  };

  home-manager.users.excalibur = { pkgs, ... }: {
    xdg.configFile = {
      "hypr/machine.conf" = {
        source = pkgs.writeText "hyprland-machine.conf" ''
          monitor=DP-1, highrr, 0x0, 1
          monitor=HDMI-A-1, 1920x1080@60, 3440x0, auto, transform, 1
          workspace=2, monitor:DP-1, default:yes
          workspace=30, monitor:HDMI-A-1, default:yes
        '';
      };
      "looking-glass/client.ini" = {
        source = pkgs.writeText "looking-glass-client.ini" ''
          [app]
          shmFile=/dev/kvmfr1
          [spice]
          host=192.168.9.12
          port=5901
        '';
      };
    };
  };

  hardware = {
    nvidia = {
      prime = {
        # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
        intelBusId = "PCI:f:0:0";
        # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
        nvidiaBusId = "PCI:e:0:0";
      };
    };
  };

  networking.interfaces.enp6s18.useDHCP = false;
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
      "30-enp6s18" = {
        matchConfig.Name = "enp6s18";
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
          Address = "192.168.9.20/24";
        };
        linkConfig = {
          RequiredForOnline = false;
        };
      };
    };
  };

  networking.hostName = "main";
  system.stateVersion = "22.11";
}
