{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules/base.nix
    ../../modules/desktop.nix
    # ../../modules/desktop-autostart.nix
    ../../modules/podman.nix
    # ../../modules/amd.nix
    # ../../modules/intel.nix
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

  networking.interfaces.enp6s0.useDHCP = false;
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
      "30-enp6s0" = {
        matchConfig.Name = "enp6s0";
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
          MulticastDNS = true;
        };
        linkConfig = {
          RequiredForOnline = false;
        };
      };
    };
  };

  home-manager.users.excalibur = { pkgs, ... }: {
    home.stateVersion = "22.11";
    wayland.windowManager.hyprland = {
      settings = {
        exec-once = [
          "brightnessctl --device radeon_bl0 set 30%"
        ];
        workspace = [
          "r[1-20], monitor:eDP-1"
          "2, monitor:eDP-1, default:yes"
          "30, monitor:HDMI-A-1, default:yes"
        ];
      };
    };
  };

  networking.hostName = "n40";
  system.stateVersion = "25.05";
}
