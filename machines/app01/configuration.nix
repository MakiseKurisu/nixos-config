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

    ../../modules/nfs-nas.nix
    #../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    ./hardware-configuration.nix
  ];

  boot = {
    kernelParams = [
      "console=ttyS0"
    ];
  };

  services = {
    technitium-dns-server = {
      enable = true;
      openFirewall = true;
    };

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

    mihomo = {
      enable = true;
      tunMode = true;
      configFile = "/home/excalibur/containers/clash.yaml";
      webui = pkgs.fetchzip {
        url = "https://github.com/MetaCubeX/metacubexd/archive/refs/tags/v1.161.0.zip";
        hash = "sha256-30y8bp0SRTRsR4inMz29r4/w/OVnf7UZ+et7MGSC34w=";
      };
    };

    iperf3 = {
      enable = true;
      openFirewall = true;
    };

    aria2 = {
      enable = true;
      openPorts = true;
      downloadDir = "/media/aria2";
      extraArguments = ''
        --rpc-listen-all \
        --input-file=/var/lib/aria2/aria2.session \
        --continue \
        --max-concurrent-downloads=100 \
        --max-overall-upload-limit=64K \
        --max-connection-per-server=10 \
        --http-accept-gzip \
        --file-allocation=falloc \
        --save-session-interval=10 \
        --bt-prioritize-piece=head,tail \
        --bt-remove-unselected-file \
        --seed-ratio 0.1 \
        --seed-time 0 \
      '';
      rpcSecretFile = pkgs.writeText "aria2-rpc-token.txt" "P3TERX";
    };
  };
  
  networking.firewall.allowedTCPPorts = [
    # mihomo
    9090
  ];
  networking.firewall.allowedTCPPortRanges = [
    # mihomo
    {
      from = 7890;
      to = 7894;
    }
  ];

  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
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
  system.stateVersion = "24.05";
}
