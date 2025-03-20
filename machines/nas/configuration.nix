{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/base.nix
    ../../modules/file-share.nix
    #../../modules/desktop.nix
    ../../modules/podman.nix
    ../../modules/intel-base.nix
    ../../modules/kernel.nix
    ../../modules/network.nix
    #../../modules/nvidia.nix
    ../../modules/packages-base.nix
    ../../modules/users-base.nix
    #../../modules/vfio.nix
    ../../modules/virtualization-base.nix

    #../../modules/nfs-nas.nix
    # ../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    ../../modules/pr/fastapi-dls.nix
    ../../modules/pr/aria2.nix

    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = lib.mkForce pkgs.unstable.linuxPackages_latest;
  };

  services = {
    # Must configure to NOT listen on 0.0.0.0:53 but 192.168.xxx.yyy:53
    # As systemd-resolved would listen on 127.0.0.53:53
    technitium-dns-server.enable = true;

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
          "acl allow execute always" = "yes";
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
          "acl allow execute always" = "yes";
        };
      };
    };

    mihomo = {
      enable = true;
      tunMode = true;
      configFile = "/var/lib/mihomo/clash.yaml";
      webui = pkgs.fetchzip {
        url = "https://github.com/MetaCubeX/metacubexd/releases/download/v1.176.2/compressed-dist.tgz";
        stripRoot = false;
        hash = "sha256-rOeeoSSDPsvMqhJAUrADzsWvdlhJnRYGoHHPE+8x/zc=";
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
        dir = "/media/raid/aria2";
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
      listenAddress = "::";
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
        "dns.protoducer.com" = https {
          locations."/" = {
            proxyPass = "http://127.0.0.1:5380/";
            extraConfig = ''
              client_max_body_size 512M;
            '';
          };
        };
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
        "downloads.protoducer.com" = http {
          locations."/" = {
            root = "/media/raid/downloads.protoducer.com";
            extraConfig = ''
              autoindex on;
            '';
          };
        };
      };
    };

    btrfs.autoScrub.enable = true;

    udev.extraRules = ''
      # Restart openwrt instance, as new net device will not be auto reconnected
      ACTION=="move", SUBSYSTEM=="net", ENV{DEVTYPE}=="wwan", ENV{INTERFACE}=="wwp0s20f0u*i5", RUN+="${pkgs.writeShellScript "restart-openwrt" ''
        if ${lib.getExe config.virtualisation.incus.package} list -c s -f compact local:openwrt |
           ${lib.getExe pkgs.gnugrep} -q RUNNING; then
          ${lib.getExe' pkgs.util-linux "logger"} -s -t "restart-openwrt" "Detect wwan reconnection, but Incus instance is already running."
          ${lib.getExe config.virtualisation.incus.package} stop local:openwrt
          ${lib.getExe config.virtualisation.incus.package} start local:openwrt
        fi
      ''}"
    '';
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
        ${lib.getExe pkgs.apt-cacher-ng} -c ${pkgs.writeTextDir "acng.conf" (lib.readFile ../../configs/acng/acng.conf)} \
          "SupportDir=${pkgs.apt-cacher-ng}/lib/apt-cacher-ng/" \
          "LocalDirs=acng-doc ${pkgs.apt-cacher-ng}/share/doc/apt-cacher-ng/"
      '';
      serviceConfig = {
        Type = "exec";
        DynamicUser = true;
        CacheDirectory = "apt-cacher-ng";
        LogsDirectory = "apt-cacher-ng";
        RuntimeDirectory = "apt-cacher-ng";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };

  networking.interfaces.eno1.useDHCP = false;
  networking.interfaces.eno2.useDHCP = false;
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
            PVID = 1;
            EgressUntagged = 1;
          }
          {
            VLAN = 10;
          }
          {
            VLAN = 20;
          }
          {
            VLAN = 30;
          }
        ];
      };
      "30-eno2" = {
        matchConfig.Name = "eno2";
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "enslaved";
        bridgeVLANs = [
          {
            PVID = 1;
            EgressUntagged = 1;
          }
          {
            VLAN = 10;
          }
          {
            VLAN = 20;
          }
          {
            VLAN = 30;
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
            PVID = 1;
            EgressUntagged = 1;
          }
          {
            VLAN = 10;
          }
          {
            VLAN = 20;
          }
          {
            VLAN = 30;
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
          RequiredForOnline = true;
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

  # systemd.services.duplicacy = {
  #   environment = {
  #     https_proxy = "socks5://10.0.20.1:1080";
  #   };
  #   script = ''
  #     set -eu
  #     ${pkgs.duplicacy}/bin/duplicacy copy -from local -to gcd -threads 2
  #   '';
  #   serviceConfig = {
  #     Type = "exec";
  #     User = "excalibur";
  #     Group = "users";
  #     WorkingDirectory = "~";
  #   };
  #   wantedBy = [ "multi-user.target" ];
  # };

  networking.hostName = "nas";
  system.stateVersion = "24.11";
}
