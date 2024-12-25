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
    # ../../modules/vfio.nix
    ../../modules/virtualization.nix

    #../../modules/nfs-nas.nix
    #../../modules/nfs-app01.nix
    ../../modules/wireguard.nix

  # ../../modules/thinkpad.nix

    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = lib.mkForce pkgs.unstable.linuxPackages_6_12;
    supportedFilesystems = [ "bcachefs" ];
  };

  home-manager.users.excalibur = { pkgs, ... }: {
    xdg.configFile = {
      "hypr/machine.conf" = {
        source = pkgs.writeText "hyprland-machine.conf" ''
          monitor=eDP-1, highres, auto, 1 # Body: internal LCD
          monitor=HDMI-A-1, highres, auto, 2 # Body: HDMI
          workspace=r[1-20], monitor:eDP-1
          workspace=2, monitor:eDP-1, default:yes
          workspace=30, monitor:HDMI-A-1, default:yes
        '';
      };
    };
  };

  networking.hostName = "n40";
  system.stateVersion = "24.05";
}
