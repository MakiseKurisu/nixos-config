{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/zone/office.nix

    inputs.home-manager.nixosModules.home-manager
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/desktop-autostart.nix
    ../../modules/podman.nix
    # ../../modules/amd.nix
    # ../../modules/intel.nix
    ../../modules/kernel.nix
    ../../modules/network.nix
    # ../../modules/nvidia.nix
    ../../modules/packages.nix
    ../../modules/users.nix
    ../../modules/vfio.nix
    ../../modules/virtualization.nix
    # ../../modules/impermanence.nix

    # ../../modules/nfs-nas.nix
    # ../../modules/nfs-app01.nix
    # ../../modules/wireguard.nix

    # ../../modules/thinkpad.nix

    inputs.nixos-hardware.nixosModules.radxa-orion-o6
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnsupportedSystem = true;

  home-manager.users.excalibur = { pkgs, ... }: {
    home.stateVersion = "25.05";
  };

  hardware.radxa.cachix.enable = true;

  networking.interfaces.enp1s0.useDHCP = false;
  networking.interfaces.enp49s0.useDHCP = false;
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
      "30-enp1s0" = {
        matchConfig.Name = "enp1s0";
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
      "30-enp49s0" = {
        matchConfig.Name = "enp49s0";
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

  systemd.settings.Manager.RuntimeWatchdogSec = "off";

  nix = {
    settings = {
      cores = 8;
      max-jobs = 2;
    };
  };

  specialisation = {
    upstream.configuration = {
      hardware.cix.sky1.bspRelease = "none";
      boot.kernelPackages = pkgs.unstable.linuxPackages_latest;
    };
  };

  networking.hostName = "orion-o6n";
  system.stateVersion = "25.11";
}
