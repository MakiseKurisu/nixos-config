{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/podman.nix
    #../../modules/intel.nix
    ../../modules/kernel.nix
    ../../modules/network.nix
    #../../modules/nvidia.nix
    ../../modules/packages.nix
    ../../modules/users.nix
    ../../modules/vfio.nix
    ../../modules/virtualization.nix

    ../../modules/nfs-nas.nix
    ../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    /etc/nixos/hardware-configuration.nix
  ];

  boot = {
    kernelParams = [
      "console=ttyS0"
    ];
  };

  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        jellyfin = {
          image = "docker.io/jellyfin/jellyfin";
          autoStart = true;
          ports = [ 
            "8096:8096"
          ];
          volumes = [
            "/home/excalibur/containers/jellyfin/cache:/cache"
            "/home/excalibur/containers/jellyfin/config:/config"
            "/media/raid/Media:/media"
          ];
          environment = {
            PUID = "1000";
            PGID = "1000";
            TZ = "Asia/Shanghai";
          };
          user = "1000:1000";
        };
      };
    };
  };

  home-manager.users.excalibur = { pkgs, ... }: {
    xdg.configFile = {
      "hypr/machine.conf" = {
        source = pkgs.writeText "hyprland-machine.conf" ''+
          monitor=DP-1, highrr, auto, 1
          workspace=DP-1, 2
        '';
      };
      "looking-glass/client.ini" = {
        source = pkgs.writeText "looking-glass-client.ini" ''
          [app]
          shmFile=/dev/kvmfr1
          [spice]
          host=192.168.9.12
          port=5901
        '';
      };
    };
  };

  networking.hostName = "nixos";
  system.stateVersion = "22.11";
}
