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
    xdg.configFile = {
      "hypr/thinkpad.conf" = {
        source = pkgs.writeText "hyprland-thinkpad.conf" ''
          monitor=eDP-1, highres, auto, 1
        '';
      };
    };
  };

  hardware = {
    graphics = {
      extraPackages = with pkgs; [
        # OpenCL filter support (hardware tonemapping and subtitle burn-in) for intel CPUs before 12th gen
        # see: https://github.com/NixOS/nixpkgs/issues/356535
        intel-compute-runtime-legacy1
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
