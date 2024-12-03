{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/base.nix
    ../../modules/file-share.nix
    #../../modules/desktop.nix
    ../../modules/podman.nix
    #../../modules/intel.nix
    ../../modules/kernel.nix
    ../../modules/network.nix
    #../../modules/nvidia.nix
    ../../modules/packages-base.nix
    ../../modules/users-base.nix
    #../../modules/vfio.nix
    #../../modules/virtualization.nix

    #../../modules/nfs-nas.nix
    ../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    ./hardware-configuration.nix
  ];

  boot = {
    kernelParams = [
      "console=ttyS0"
    ];
    loader.efi.efiSysMountPoint = "/boot/efi";
  };

  services = {
    nfs.server = {
      exports = ''
        /media         192.168.9.0/24(rw,fsid=0,no_subtree_check)
        /media/backup  192.168.9.0/24(rw,nohide,insecure,no_subtree_check)
        /media/raid    192.168.9.0/24(rw,nohide,insecure,no_subtree_check)
      '';
    };

    samba-wsdd.enable = true;
    samba = {
      settings = {
        backup = {
          path = "/media/backup";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "excalibur";
          "force group" = "users";
        };
        raid = {
          path = "/media/raid";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "excalibur";
          "force group" = "users";
        };
      };
    };
  };

  environment = {
    systemPackages =
      with pkgs; [
        duplicacy
      ];
  };

  systemd.services.duplicacy = {
    environment = {
      https_proxy = "socks5://10.0.20.1:1080";
    };
    script = ''
      set -eu
      ${pkgs.duplicacy}/bin/duplicacy copy -from local -to gcd -threads 2
    '';
    serviceConfig = {
      Type = "exec";
      User = "excalibur";
      Group = "users";
      WorkingDirectory = "~";
    };
    wantedBy = [ "multi-user.target" ];
  };

  networking.hostName = "nas";
  system.stateVersion = "22.11";
}
