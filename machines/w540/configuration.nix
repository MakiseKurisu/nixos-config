{ config, pkgs, lib, ... }:

{
  imports = [
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
    #../../modules/wireguard.nix

    /etc/nixos/hardware-configuration.nix
  ];

/*
  hardware = {
    nvidia = {
      package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.legacy_470;
    };
  };
*/

  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    kernelPackages = lib.mkForce pkgs.unstable.linuxPackages_testing_bcachefs;
  };

  home-manager.users.excalibur = { pkgs, ... }: {
    xdg.configFile = {
      "hypr/machine.conf" = {
        source = pkgs.writeText "hyprland-machine.conf" ''
          monitor=eDP-1, highres, auto, 1.5
          exec-once=[workspace 1 silent] firefox
        '';
      };
    };
  };

  networking.hostName = "W540";
  system.stateVersion = "23.05";
}
