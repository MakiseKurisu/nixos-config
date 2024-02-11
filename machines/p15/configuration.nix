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

  networking.hostName = "p15";
  system.stateVersion = "23.05";
}
