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
    #../../modules/nvidia.nix
    ../../modules/packages.nix
    ../../modules/users.nix
    ../../modules/vfio.nix
    ../../modules/virtualization.nix

    #../../modules/nfs-nas.nix
    #../../modules/nfs-app01.nix
    ../../modules/wireguard.nix

    ../../modules/thinkpad.nix

    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = lib.mkForce pkgs.unstable.linuxPackages_6_12;
    loader.efi.efiSysMountPoint = "/boot/efi";
  };

  home-manager.users.excalibur = { pkgs, ... }: {
    wayland.windowManager.hyprland.settings = {
      workspace = [
        "r[1-20], monitor:eDP-1"
        "2, monitor:eDP-1, default:yes"
        "30, monitor:DP-1, default:yes"
        "40, monitor:DP-2, default:yes"
        "50, monitor:DP-3, default:yes"
      ];
    };
  };

  networking.hostName = "w540";
  system.stateVersion = "23.05";
}
