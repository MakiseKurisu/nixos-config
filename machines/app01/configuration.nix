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

    ../../modules/pr/fastapi-dls.nix
    ../../modules/pr/aria2.nix

    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    supportedFilesystems = [ "bcachefs" ];
  };

  services = {
    # Must configure to NOT listen on 0.0.0.0:53 but 192.168.xxx.yyy:53
    # As systemd-resolved would listen on 127.0.0.53:53
    technitium-dns-server.enable = true;

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
      rpcSecretFile = pkgs.writeText "aria2-rpc-token.txt" "P3TERX";
      openPorts = true;
      serviceUMask = "0007";
      settings = {
        dir = "/srv/aria2";
        rpc-listen-all = true;
        input-file = "/var/lib/aria2/aria2.session";
        continue = true;
        max-concurrent-downloads = 100;
        max-overall-upload-limit = "64K";
        max-connection-per-server = 10;
        http-accept-gzip = true;
        file-allocation = "falloc";
        save-session-interval = 10;
        bt-prioritize-piece = "head,tail";
        bt-remove-unselected-file = true;
        seed-ratio = 0.1;
        seed-time = 0;
      };
    };

    jellyfin.enable = true;

    pykms = {
      enable = true;
      openFirewallPort = true;
    };

    home-assistant = {
      enable = true;
      extraPackages = python3Packages: with python3Packages; [
        gtts
      ];
      extraComponents = [
        "default_config"
        "met"
        "mobile_app"
        "radio_browser"
        "tuya"
        "xiaomi_miio"
      ];
      config = {
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [ "127.0.0.1" ];
        };
        homeassistant = {
          unit_system = "metric";
          name = "Home";
        };
        mobile_app = {};
      };
    };

    fastapi-dls = {
      enable = true;
      package = pkgs.pr-fastapi-dls.fastapi-dls;
      listenPort = 8001;
      dlsAddress = "dls.protoducer.com";
      dlsPort = 443;
    };

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
        "ha.protoducer.com" = http {
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:8123/";
          };
        };
        "dls.protoducer.com" = https { locations."/".proxyPass = "https://127.0.0.1:8001/"; };
      };
    };
  };

  networking.firewall.allowedUDPPorts = [
    53 # technitium-dns-server
  ];
  networking.firewall.allowedTCPPorts = [
    53 # technitium-dns-server
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
    e1000e = {
      script = ''
        set -eu
        ${lib.getExe pkgs.ethtool} -K eno1 tso off gso off
      '';
      serviceConfig = {
        Type = "oneshot";
      };
      wantedBy = [ "sys-subsystem-net-devices-eno1.device" ];
    };
  };

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
      };
      "40-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          LinkLocalAddressing = false;
        };
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
          Address = "192.168.9.2/24";
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
