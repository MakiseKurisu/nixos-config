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

    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot = {
    kernelModules = [
      "nct6775"
      "w83627hf_wdt"
    ];
    extraModulePackages = with config.boot.kernelPackages; [ r8125 ];
    blacklistedKernelModules = [ "r8169" ];
  };

  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

  hardware = {
    graphics = {
      extraPackages = with pkgs; [
        # OpenCL filter support on 12th gen or newer
        # intel-compute-runtime
        # OpenCL filter support up to 11th gen
        # see: https://github.com/NixOS/nixpkgs/issues/356535
        intel-compute-runtime-legacy1

        # VAAPI on 5th gen or newer. LIBVA_DRIVER_NAME=iHD
        intel-media-driver
        # VAAPI up to 4th gen. LIBVA_DRIVER_NAME=i965
        # intel-vaapi-driver

        # QSV on 11th gen or newer
        # vpl-gpu-rt
        # QSV up to 11th gen
        intel-media-sdk
      ];
    };
  };

  power.ups = {
    enable = true;
    mode = "netserver";
    openFirewall = true;
    users = {
      admin = {
        actions = [ "set" "fsd" ];
        instcmds = [ "all" ];
        passwordFile = "/var/lib/ups/adminPassword";
        upsmon = "primary";
      };
      guest = {
        passwordFile = "${pkgs.writeText "ups-guest.txt" "guest"}";
        upsmon = "secondary";
      };
    };
    ups = {
      SMT1500I = {
        driver = "usbhid-ups";
        port = "auto";
        directives = [
          "vendorid = 051d"
          "productid = 0003"
          "serial = AS1048210050"
        ];
      };
    };
    upsd = {
      listen = [
        {
          address = "127.0.0.1";
        }
        {
          address = "192.168.9.3";
        }
      ];
    };
    upsmon = {
      monitor = {
        SMT1500I = {
          system = "SMT1500I";
          type = "primary";
          user = "admin";
        };
      };
    };
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
        ibeacon-ble
      ];
      extraComponents = [
        "bluetooth"
        "command_line"
        "default_config"
        "ffmpeg"
        "homekit"
        "jellyfin"
        "keyboard_remote"
        "logger"
        "met"
        "mobile_app"
        "open_meteo"
        "ping"
        "radio_browser"
        "shell_command"
        "vlc"
        "wake_on_lan"
        "whisper"
        "workday"
        "wyoming"
        "xiaomi_aqara"
        "xiaomi_ble"
        "xiaomi_miio"
        "zeroconf"
      ];
      config = {
        automation = "!include automations.yaml";
        default_config = {};
        frontend = {
          themes = "!include_dir_merge_named themes";
        };
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [ "127.0.0.1" ];
        };
        homeassistant = {
          debug = false;
          unit_system = "metric";
          name = "Home";
          external_url = "http://ha.protoducer.com";
          internal_url = "http://ha.protoducer.com";
        };
        keyboard_remote = {
          device_name = "Chromecast Remote";
          type = "key_down";
        };
        logger = {
          default = "warning";
        };
      };
      configWritable = true;
      customComponents = with pkgs.home-assistant-custom-components; [
        pkgs.unstable.home-assistant-custom-components.xiaomi_home
        tuya_local
        ntfy
        bodymiscale
        smartir
        midea_ac_lan
        xiaomi_gateway3
        pkgs.unstable.home-assistant-custom-components.xiaomi_miot
      ];
    };

    fastapi-dls = {
      enable = true;
      package = pkgs.pr-fastapi-dls.fastapi-dls;
      port = 8001;
      dlsAddress = "dls.protoducer.com";
      dlsPort = 443;
    };

    meshcentral = {
      enable = true;
      settings = {
        settings = {
          cert = "mc.protoducer.com";
          port = 4430;
          portBind = "127.0.0.1";
          aliasPort = 443;
          redirPort = 0;
        };
      };
    };

    nextcloud = {
      config = {
        adminuser = "Excalibur";
        adminpassFile = "${pkgs.writeText "adminpass" "adminpass"}";
        dbtype = "sqlite";
      };
      enable = false;
      hostName = "nc.protoducer.com";
      notify_push.enable = false;
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
        "ol.protoducer.com" = https { locations."/".proxyPass = "http://127.0.0.1:5244/"; };
        "ha.protoducer.com" = http_https {
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:8123/";
          };
        };
        "dls.protoducer.com" = https { locations."/".proxyPass = "https://127.0.0.1:8001/"; };
        "downloads.protoducer.com" = http_https {
          locations."/" = {
            root = "/media/raid/downloads.protoducer.com";
            extraConfig = ''
              autoindex on;
            '';
          };
        };
        "mc.protoducer.com" = https {
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "https://127.0.0.1:4430/"; 
          };
        };
        "nc.protoducer.com" = https {};
        "pico.protoducer.com" = https {
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:14500/";
          };
        };
      };
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
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
    openlist = {
      after = [
        "network.target"
      ];
      script = ''
        set -eu
        ${lib.getExe pkgs.unstable.openlist} server --data /var/lib/openlist
      '';
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        DynamicUser = true;
        StateDirectory = "openlist";
        WorkingDirectory = "/var/lib/openlist";
        ReadWritePaths = [
          "/media/raid/OpenList"
        ];
      };
      wantedBy = [ "multi-user.target" ];
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
          {
            VLAN = 40;
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
          {
            VLAN = 40;
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
          {
            VLAN = 40;
          }
        ];
      };
      "40-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          LinkLocalAddressing = false;
          DHCP = false;
          LLDP = false;
          EmitLLDP = false;
          IPv6AcceptRA = false;
          IPv6SendRA = false;
        };
        bridgeConfig = {
          HairPin = true;
        };
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
          {
            VLAN = 40;
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
          Domains = "protoducer.com vamrs.org";
          Address = "192.168.8.3/24";
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
