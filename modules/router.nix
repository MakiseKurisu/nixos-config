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

  systemd = {
    services = {
      qmi_wwan = {
        script = ''
          set -eu

          while read -r; do
            REPLY="$(cut -d ' ' -f 7 <<< "$REPLY" | sed -E "s/(.*)\:.*/\1/")"
            ${lib.getExe' pkgs.util-linux "logger"} -s -t "qmi_wwan" "Detect modem lock up."
            echo "$REPLY" > /sys/bus/usb/drivers/usb/unbind
            sleep 1
            echo "$REPLY" > /sys/bus/usb/drivers/usb/bind
          done < <(journalctl -kfS now --grep "qmi_wwan.*wwan.*: NETDEV WATCHDOG: CPU: .*: transmit queue .* timed out .* ms")
        '';
        wantedBy = [ "multi-user.target" ];
      };
    };

    network = {
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
    };
  };
}
