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
    ../../modules/virtualization.nix

    ../../modules/nfs-nas.nix
    #../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    supportedFilesystems = [ "bcachefs" ];
  };

  services = {
    technitium-dns-server = {
      enable = true;
      openFirewall = true;
    };

    nfs.server = {
      exports = ''
        /srv        192.168.9.0/24(rw,fsid=0,no_subtree_check)
        /srv/aria2  192.168.9.0/24(rw,nohide,insecure,no_subtree_check)
      '';
    };

    samba-wsdd.enable = true;
    samba = {
      shares = {
        aria2 = {
          path = "/srv/aria2";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "excalibur";
          "force group" = "users";
          "acl allow execute always" = "yes";
        };
      };
    };

    mihomo = {
      enable = true;
      tunMode = true;
      configFile = "/var/lib/mihomo/clash.yaml";
      webui = pkgs.fetchzip {
        url = "https://github.com/MetaCubeX/metacubexd/releases/download/v1.169.0/compressed-dist.tgz";
        stripRoot = false;
        hash = "sha256-L0HHTh20qpTQiOJQTr5GgZF17JuhHHFSfn5Fht2V/rw=";
      };
    };

    iperf3 = {
      enable = true;
      openFirewall = true;
    };

    aria2 = {
      enable = true;
      openPorts = true;
      downloadDir = "/srv/aria2";
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

    jellyfin.enable = true;

    nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedZstdSettings = true;
      recommendedProxySettings = true;
      virtualHosts = let
        https = host: host // {
          sslCertificate = "/var/lib/nginx/cert.pem";
          sslCertificateKey = "/var/lib/nginx/key.pem";
          forceSSL = true;
          kTLS = true;
        };
        http = host: host // {
          rejectSSL = true;
        }; in {
        "_" = https { locations."/".return = "404"; };
        "apt.protoducer.com" = http { locations."/".proxyPass = "http://127.0.0.1:3142/"; };
        "aria.protoducer.com" = http {
          locations = {
            "/".root = "${pkgs.ariang}/share/ariang/";
            "/jsonrpc" = {
              proxyPass = "http://127.0.0.1:6800/jsonrpc";
              extraConfig = ''
                add_header 'Access-Control-Allow-Origin' '*' always;
              '';
            };
          };
        };
        "dns.protoducer.com" = https { locations."/".proxyPass = "http://127.0.0.1:5380/"; };
        "jf.protoducer.com" = https {
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:8096/";
          };
        };
        "proxy.protoducer.com" = https {
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:9090/";
          };
        };
      };
    };
  };

  networking.firewall.allowedUDPPorts = [
    # 53 # technitium-dns-server
  ];
  networking.firewall.allowedTCPPorts = [
    # 53 # technitium-dns-server
    80 # nginx
    443 # nginx
    9090 # mihomo
  ];
  networking.firewall.allowedTCPPortRanges = [
    # mihomo
    {
      from = 7890;
      to = 7894;
    }
  ];

  systemd.services = {
    apt-cacher-ng = {
      script = ''
        set -eu
        ${lib.getExe pkgs.apt-cacher-ng} -c /var/lib/apt-cacher-ng/ \
          "SupportDir=${pkgs.apt-cacher-ng}/lib/apt-cacher-ng/" \
          "LocalDirs=acng-doc ${pkgs.apt-cacher-ng}/share/doc/apt-cacher-ng/"
      '';
      serviceConfig = {
        Type = "exec";
        DynamicUser = true;
        StateDirectory = "apt-cacher-ng";
        CacheDirectory = "apt-cacher-ng";
        LogsDirectory = "apt-cacher-ng";
        RuntimeDirectory = "apt-cacher-ng";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };

  # virtualisation = {
  #   oci-containers = {
  #     backend = "podman";
  #     containers = {
  #       vlmcsd = {
  #         image = "docker.io/mikolatero/vlmcsd";
  #         autoStart = true;
  #         ports = [
  #           "1688:1688"
  #         ];
  #         environment = {
  #           PUID = "1000";
  #           PGID = "100";
  #           TZ = "Asia/Shanghai";
  #         };
  #       };
  #       dls = {
  #         image = "docker.io/collinwebdesigns/fastapi-dls";
  #         autoStart = true;
  #         ports = [
  #           "8443:443"
  #         ];
  #         volumes = [
  #           "/home/excalibur/containers/fastapi-dls/cert/:/app/cert/"
  #           "/home/excalibur/containers/fastapi-dls/database/:/app/database/"
  #         ];
  #         environment = {
  #           TZ = "Asia/Shanghai";
  #           DLS_URL = "192.168.9.2";
  #           DLS_PORT = "8443";
  #           LEASE_EXPIRE_DAYS = "90";
  #           DATABASE = "sqlite:////app/database/db.sqlite";
  #           DEBUG = "false";
  #         };
  #       };
  #     };
  #   };
  # };

  networking.interfaces.eno1.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = false;
  systemd.network = {
    netdevs = {
       "20-br0" = {
         netdevConfig = {
           Kind = "bridge";
           Name = "br0";
         };
        bridgeConfig = {
          STP = true;
          VLANFiltering = true;
        };
       };
    };
    networks = {
      "30-eno1" = {
        matchConfig.Name = "eno1";
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "enslaved";
        bridgeVLANs = [
          {
            bridgeVLANConfig = {
              PVID = 1;
              EgressUntagged = 1;
            };
          }
          {
            bridgeVLANConfig = {
              VLAN = 10;
            };
          }
          {
            bridgeVLANConfig = {
              VLAN = 20;
            };
          }
          {
            bridgeVLANConfig = {
              VLAN = 30;
            };
          }
        ];
        networkConfig = {
          LinkLocalAddressing = false;
          DHCP = false;
        };
      };
      "30-enp2s0" = {
        matchConfig.Name = "enp2s0";
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "enslaved";
        bridgeVLANs = [
          {
            bridgeVLANConfig = {
              PVID = 1;
              EgressUntagged = 1;
            };
          }
          {
            bridgeVLANConfig = {
              VLAN = 10;
            };
          }
          {
            bridgeVLANConfig = {
              VLAN = 20;
            };
          }
          {
            bridgeVLANConfig = {
              VLAN = 30;
            };
          }
        ];
        networkConfig = {
          LinkLocalAddressing = false;
          DHCP = false;
        };
      };
      "40-br0" = {
        matchConfig.Name = "br0";
        bridgeConfig = {};
        bridgeVLANs = [
          {
            bridgeVLANConfig = {
              PVID = 1;
              EgressUntagged = 1;
            };
          }
          {
            bridgeVLANConfig = {
              VLAN = 10;
            };
          }
          {
            bridgeVLANConfig = {
              VLAN = 20;
            };
          }
          {
            bridgeVLANConfig = {
              VLAN = 30;
            };
          }
        ];
        networkConfig = {
          LinkLocalAddressing = false;
          DHCP = false;
        };
        vlan = [
          "vlan20"
        ];
        linkConfig = {
          RequiredForOnline = false;
        };
      };
      "50-vlan20" = {
        matchConfig.Name = "vlan20";
        networkConfig = {
          DHCP = true;
          Domains = "protoducer.com vamrs.org";
        };
        linkConfig = {
          RequiredForOnline = false;
        };
      };
    };
  };

  networking.hostName = "app01";
  system.stateVersion = "24.05";
}
