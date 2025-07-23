{ config, pkgs, lib, inputs, ... }:

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
    ../../modules/impermanence.nix

    #../../modules/nfs-nas.nix
    # ../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    ../../modules/pr/fastapi-dls.nix
    ../../modules/pr/pico-rpa.nix

    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot = {
    kernelModules = [
      "iptable_mangle"
      "ip6table_mangle"
    ];
    extraModulePackages = with config.boot.kernelPackages; [ r8125 ];
    blacklistedKernelModules = [ "r8169" ];
  };

  environment.persistence."/persistent/system".directories = [
    { directory = "/media/aria2"; user = "aria2"; group = "aria2"; mode = "0770"; }
  ];

  services = {
    # Must configure to NOT listen on 0.0.0.0:53 but 192.168.xxx.yyy:53
    # As systemd-resolved would listen on 127.0.0.53:53
    technitium-dns-server.enable = true;

    nfs.server = {
      exports = ''
        /media        192.168.9.0/24(rw,fsid=0,no_subtree_check)
        /media/aria2  192.168.9.0/24(rw,nohide,insecure,no_subtree_check)
      '';
    };

    samba = {
      settings = {
        aria2 = {
          path = "/media/aria2";
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
      webui = pkgs.metacubexd;
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
        dir = "/media/aria2";
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
      port = 8001;
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
        ssl = {
          sslCertificate = "/var/lib/nginx/cert.pem";
          sslCertificateKey = "/var/lib/nginx/key.pem";
          kTLS = true;
        };
        https = host: host // ssl // {
          forceSSL = true;
        };
        http = host: host // ssl // {
          rejectSSL = true;
        };
        http_https = host: host // ssl // {
          addSSL = true;
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
        "jf.protoducer.com" = http_https {
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
            root = "/media/aria2";
            extraConfig = ''
              autoindex on;
            '';
          };
        };
        "pico.protoducer.com" = https {
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:14500/";
          };
        };
      };
    };

    btrfs.autoScrub.enable = true;

    udev.extraRules = ''
      # Restart openwrt instance, as new net device will not be auto reconnected
      ACTION=="move", SUBSYSTEM=="net", ENV{DEVTYPE}=="wwan", ENV{INTERFACE}=="wwan*", ENV{TAGS}==":systemd:", RUN+="${pkgs.writeShellScript "restart-openwrt" ''
        if ${lib.getExe config.virtualisation.incus.package} list -c s -f compact local:openwrt |
           ${lib.getExe pkgs.gnugrep} -q RUNNING; then
          ${lib.getExe' pkgs.util-linux "logger"} -s -t "restart-openwrt" "Detect wwan reconnection, but Incus instance is already running."
          ${lib.getExe config.virtualisation.incus.package} stop local:openwrt
        else
          ${lib.getExe' pkgs.util-linux "logger"} -s -t "restart-openwrt" "Detect wwan reconnection, and Incus instance is not running."
        fi
        ${lib.getExe config.virtualisation.incus.package} start local:openwrt
      ''}"
    '';

    pico-remote-play-assistant = {
      enable = true;
      package = pkgs.pr-pico-rpa.pico-remote-play-assistant;
      openFirewall = true;
      cjkfonts = true;
      xpra = {
        package = pkgs.pr-pico-rpa.xpra;
        auth = "none";
      };
    };

    thermald.enable = false;  # Disable on older Intel systems
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
  systemd.network = {
    links = {
      "40-wwan0" = {
        matchConfig = {
          Type = "wwan";
          Property = "ID_SERIAL_SHORT=6f345e48";
        };
        linkConfig = {
          Name = "wwan10";
        };
      };
    };
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
          RequiredForOnline = false;
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

  networking.hostName = "app01";
  system.stateVersion = "25.05";
}
