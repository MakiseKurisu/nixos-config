{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/base.nix
    #../../modules/file-share.nix
    #../../modules/desktop.nix
    ../../modules/podman.nix
    #../../modules/intel.nix
    #../../modules/kernel.nix
    ../../modules/network.nix
    #../../modules/nvidia.nix
    ../../modules/packages-base.nix
    ../../modules/services.nix
    ../../modules/users-base.nix
    #../../modules/vfio.nix
    #../../modules/virtualization.nix

    #../../modules/nfs-nas.nix
    #../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
      efi.efiSysMountPoint = "/boot/efi";
    };
    kernelParams = [
      "console=ttyS1,115200n8"
      "console=tty1"
    ];
  };

  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        clash = {
          image = "docker.io/dreamacro/clash-premium";
          autoStart = true;
          ports = [
            "7890:7890"
            "7891:7891"
            "9090:9090"
          ];
          volumes = [
            "/home/excalibur/containers/clash.yml:/root/.config/clash/config.yaml"
          ];
          environment = {
            PUID = "1000";
            PGID = "1000";
            TZ = "Asia/Shanghai";
          };
        };
        yacd = {
          image = "docker.io/haishanh/yacd";
          autoStart = true;
          ports = [
            "8080:80"
          ];
          environment = {
            PUID = "1000";
            PGID = "1000";
            TZ = "Asia/Shanghai";
            YACD_DEFAULT_BACKEND = "http://rpi3:9090";
          };
        };
        vlmcsd = {
          image = "docker.io/mikolatero/vlmcsd";
          autoStart = true;
          ports = [
            "1688:1688"
          ];
          environment = {
            PUID = "1000";
            PGID = "1000";
            TZ = "Asia/Shanghai";
          };
        };
      };
    };
  };

  networking.hostName = "rpi3";
  system.stateVersion = "23.05";
}
