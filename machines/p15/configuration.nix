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
    ../../modules/wireguard.nix

    /etc/nixos/hardware-configuration.nix
  ];

  boot = {
    extraModprobeConfig = ''
      options vfio-pci ids=1c5c:1639,10de:1fb9,10de:10fa disable_idle_d3=1
    '';
  };

  home-manager.users.excalibur = { pkgs, ... }: {
    xdg.configFile = {
      "hypr/machine.conf" = {
        source = pkgs.writeText "hyprland-machine.conf" ''
          monitor=eDP-1, highres, auto, 1
          exec-once=[workspace 1 silent] firefox
          exec-once=brightnessctl --device "tpacpi::kbd_backlight" set 100%
        '';
      };
    };
  };
  networking.hostName = "P15";
  system.stateVersion = "23.05";
}
