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
    ../../modules/nvidia.nix
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

  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  home-manager.users.excalibur = { pkgs, ... }: {
    wayland.windowManager.hyprland.settings = {
      monitor = [
        "eDP-1, highres, auto, 1"
      ];
    };
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
        intel-media-driver
        # VAAPI up to 4th gen. LIBVA_DRIVER_NAME=i965
        # intel-vaapi-driver

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

  networking.hostName = "p15";
  system.stateVersion = "23.05";
}
