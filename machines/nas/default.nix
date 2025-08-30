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
    ../../modules/wwan.nix
    ../../modules/router.nix

    #../../modules/nfs-nas.nix
    # ../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    ../../modules/pr/fastapi-dls.nix
    ../../modules/pr/pico-rpa.nix
    ../../modules/pr/xiaomi_home.nix

    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot = {
    kernelModules = [
      "w83627hf_wdt"
    ];
    extraModulePackages = with config.boot.kernelPackages; [ r8125 ];
    blacklistedKernelModules = [ "r8169" ];
  };

  services = {
    nfs.server = {
      exports = ''
        /media         192.168.9.0/24(rw,fsid=0,no_subtree_check)
        /media/backup  192.168.9.0/24(rw,nohide,insecure,no_subtree_check)
        /media/raid    192.168.9.0/24(rw,nohide,insecure,no_subtree_check)
      '';
    };

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

    aria2 = {
      enable = true;
      rpcSecretFile = pkgs.writeText "aria2-rpc-token.txt" "P3TERX";
      openPorts = true;
      serviceUMask = "0007";
      settings = {
        bt-prioritize-piece = "head,tail";
        bt-remove-unselected-file = true;
        continue = true;
        dir = "/media/raid/aria2";
        file-allocation = "falloc";
        http-accept-gzip = true;
        input-file = "/var/lib/aria2/aria2.session";
        max-concurrent-downloads = 100;
        max-connection-per-server = 10;
        max-overall-upload-limit = "64K";
        rpc-listen-all = true;
        save-session-interval = 10;
        seed-ratio = 0.1;
        seed-time = 0;
        show-console-readout = false;
        summary-interval = 0;
      };
    };

    jellyfin.enable = true;

    home-assistant = {
      enable = true;
      extraPackages = python3Packages: with python3Packages; [
        gtts
      ];
      extraComponents = [
        "default_config"
        "ffmpeg"
        "homekit"
        "met"
        "mobile_app"
        "radio_browser"
        "xiaomi_ble"
        "zeroconf"
      ];
      config = {
        default_config = {};
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [ "127.0.0.1" ];
        };
        homeassistant = {
          unit_system = "metric";
          name = "Home";
          internal_url = "http://ha.protoducer.com";
        };
      };
      customComponents = with pkgs.home-assistant-custom-components; [
        pkgs.pr-xiaomi_home.home-assistant-custom-components.xiaomi_home
        tuya_local
        ntfy
        bodymiscale
        smartir
        midea_ac_lan
      ];
    };

    fastapi-dls = {
      enable = true;
      package = pkgs.pr-fastapi-dls.fastapi-dls;
      port = 8001;
      dlsAddress = "dls.protoducer.com";
      dlsPort = 443;
    };

    nginx = {
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
        "jf.protoducer.com" = http_https {
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:8096/";
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
        "pico.protoducer.com" = https {
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:14500/";
          };
        };
      };
    };

    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="watchdog", ENV{DEVPATH}=="/devices/virtual/watchdog/watchdog*", SYMLINK+="watchdog"
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
  };

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
        ${lib.getExe pkgs.ethtool} -K eno1 tso off
      '';
      serviceConfig = {
        Type = "oneshot";
      };
      wantedBy = [ "sys-subsystem-net-devices-eno1.device" ];
    };
  };

  networking.interfaces.eno1.useDHCP = false;
  networking.interfaces.eno2.useDHCP = false;
  networking.interfaces.enp7s0.useDHCP = false;
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
      "30-enp7s0" = {
        matchConfig.Name = "enp7s0";
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
          "vlan30"
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
          Address = "192.168.9.3/24";
        };
        linkConfig = {
          RequiredForOnline = false;
        };
      };
      "50-vlan30" = {
        matchConfig.Name = "vlan30";
        networkConfig = {
          DHCP = true;
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

  networking.hostName = "nas";
  system.stateVersion = "25.05";
}
