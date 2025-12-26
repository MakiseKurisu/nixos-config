{ config, lib, pkgs, inputs, options, ... }:

{
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      amneziawg
    ];
    kernelModules = [
      "amneziawg"
      "iptable_mangle"
      "ip6table_mangle"
    ];
  };

  services = {
    # Must configure to NOT listen on 0.0.0.0:53 but 192.168.xxx.yyy:53
    # As systemd-resolved would listen on 127.0.0.53:53
    technitium-dns-server.enable = true;

    mihomo = {
      enable = true;
      tunMode = true;
      configFile = "${config.sops.templates."mihomo.yaml".path}";
      webui = pkgs.metacubexd;
    };

    v2ray = {
      enable = false;
      configFile = "${config.sops.templates."v2ray.json".path}";
    };

    iperf3 = {
      enable = true;
      openFirewall = true;
    };

    pykms = {
      enable = true;
      listenAddress = "::";
      openFirewallPort = true;
    };

    nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
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
        "dns.protoducer.com" = https {
          locations."/" = {
            proxyPass = "http://127.0.0.1:5380/";
            extraConfig = ''
              client_max_body_size 512M;
            '';
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

  networking = {
    firewall = {
      allowedUDPPorts = [
        53 # technitium-dns-server
      ];
      allowedTCPPorts = [
        53 # technitium-dns-server
        80 # nginx
        443 # nginx
        1080 # wg2 dante
        7899 # v2ray
        9090 # mihomo
      ];
      allowedTCPPortRanges = [
        # mihomo
        {
          from = 7890;
          to = 7894;
        }
      ];
    };
    nat = {
      enable = true;
      enableIPv6 = true;
      internalInterfaces = [ "wg2" ];
      externalInterface = "vlan20";
      forwardPorts = [
        {
          sourcePort = 1080;
          destination = "10.0.20.1:1080";
        }
      ];
    };
    wireguard = {
      useNetworkd = false;
      interfaces = {
        wg2 = {
          type = "amneziawg";
          privateKeyFile = lib.mkDefault config.sops.secrets.wg2_private_key.path;
          mtu = 1280;
          listenPort = 51820;
          ips = lib.mkDefault [
            "10.0.20.3/32"
            "fd20::3/128"
          ];
          extraOptions = {
            Jc = 1;
            Jmin = 10;
            Jmax = 50;
            S1 = 16;
            S2 = 48;
          };
          dynamicEndpointRefreshSeconds = 5;
          peers = [
            {
              publicKey = "mM6UKv/6OJW0re4/R24TGnxhA5g+7XHIkM/iGCSR7Tk=";
              persistentKeepalive = 25;
              endpoint = "140.245.83.173:51820";
              allowedIPs = [
                "10.0.20.0/24"
                "fd20::/64"
              ];
            }
          ];
        };
      };
    };
  };
}
