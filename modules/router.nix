{ config, lib, pkgs, inputs, options, ... }:

{
  boot = {
    kernelModules = [
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
      configFile = "/var/lib/mihomo/clash.yaml";
      webui = pkgs.metacubexd;
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
}
