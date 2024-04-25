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
    kernelPackages = lib.mkForce pkgs.linuxPackages_6_7;
    loader.efi.efiSysMountPoint = "/boot/efi";
  };

  home-manager.users.excalibur = { pkgs, ... }: {
    xdg.configFile = {
      "hypr/thinkpad.conf" = {
        source = pkgs.writeText "hyprland-thinkpad.conf" ''
          monitor=eDP-1, highres, auto, 1.5 # Body: internal LCD
          monitor=DP-1, highres, auto, 2 # Body: mini DisplayPort
          monitor=DP-2, highres, auto, 2 # Unknown:
          monitor=DP-3, highres, auto, 2 # Dock: HDMI
          workspace=eDP-1, 2
          workspace=DP-1, 30
          workspace=DP-2, 40
          workspace=DP-3, 50
        '';
      };
    };
  };

  networking.hostName = "w540";
  system.stateVersion = "23.05";
}
