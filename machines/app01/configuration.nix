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
    ../../modules/services.nix
    ../../modules/users-base.nix
    #../../modules/vfio.nix
    #../../modules/virtualization.nix

    ../../modules/nfs-nas.nix
    #../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    /etc/nixos/hardware-configuration.nix
  ];

  services = {
    nfs.server = {
      exports = ''
        /media        192.168.9.0/24(rw,fsid=0,no_subtree_check)
        /media/aria2  192.168.9.0/24(rw,nohide,insecure,no_subtree_check)
      '';
    };

    samba-wsdd.enable = true;
    samba = {
      shares = {
        aria2 = {
          path = "/media/aria2";
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
            PGID = "100";
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
            PGID = "100";
            TZ = "Asia/Shanghai";
            YACD_DEFAULT_BACKEND = "http://app01.protoducer.com:9090";
          };
        };
        acng = {
          image = "docker.io/mbentley/apt-cacher-ng";
          autoStart = true;
          ports = [ 
            "3142:3142"
          ];
          volumes = [
            "/home/excalibur/containers/acng.conf:/etc/apt-cacher-ng/acng.conf"
            "/home/excalibur/containers/acng/:/var/cache/apt-cacher-ng/"
          ];
          environment = {
            PUID = "1000";
            PGID = "100";
            TZ = "Asia/Shanghai";
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
            PGID = "100";
            TZ = "Asia/Shanghai";
          };
        };
        npm = {
          image = "docker.io/jc21/nginx-proxy-manager";
          autoStart = true;
          ports = [ 
            "80:80"
            "81:81"
            "443:443"
          ];
          volumes = [
            "/home/excalibur/containers/npm/:/data/"
            "/home/excalibur/containers/npm-letsencrypt/:/etc/letsencrypt/"
          ];
          environment = {
            PUID = "1000";
            PGID = "100";
            TZ = "Asia/Shanghai";
          };
        };
        dls = {
          image = "docker.io/collinwebdesigns/fastapi-dls";
          autoStart = true;
          ports = [ 
            "8443:443"
          ];
          volumes = [
            "/home/excalibur/containers/fastapi-dls/cert/:/app/cert/"
            "/home/excalibur/containers/fastapi-dls/database/:/app/database/"
          ];
          environment = {
            TZ = "Asia/Shanghai";
            DLS_URL = "192.168.9.2";
            DLS_PORT = "8443";
            LEASE_EXPIRE_DAYS = "90";
            DATABASE = "sqlite:////app/database/db.sqlite";
            DEBUG = "false";
          };
        };
        aria2-pro = {
          image = "docker.io/p3terx/aria2-pro";
          autoStart = true;
          ports = [ 
            "6800:6800"
            "6888:6888"
            "6888:6888/udp"
          ];
          volumes = [
            "/home/excalibur/containers/aria2-pro/:/config/"
            "/media/aria2/:/downloads/"
          ];
          environment = {
            PUID = "1000";
            PGID = "100";
            UMASK_SET = "022";
            RPC_SECRET = "P3TERX";
            RPC_PORT = "6800";
            LISTEN_PORT = "6888";
            DISK_CACHE = "64M";
            IPV6_MODE = "false";
            UPDATE_TRACKERS = "true";
            CUSTOM_TRACKER_URL = "";
            TZ = "Asia/Shanghai";
          };
        };
        ariang = {
          image = "docker.io/p3terx/ariang";
          autoStart = true;
          ports = [ 
            "6880:6880"
          ];
          environment = {
            TZ = "Asia/Shanghai";
          };
        };
      };
    };
  };

  networking.hostName = "app01";
  system.stateVersion = "23.11";
}
