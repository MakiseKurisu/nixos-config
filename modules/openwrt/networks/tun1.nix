{ service_ip
, ...
}: {
  etc = {
    "proxy/tun1.yaml".text = ''
      tunnel:
        name: tun1
        mtu: 8500
        multi-queue: true
        ipv4: 10.0.41.1
        ipv6: "fd41::1"
      socks5:
        port: 7899
        address: ${service_ip}
        udp: udp
        mark: 437
    '';
    "rc.local".text = ''
      /usr/bin/hev-socks5-tunnel /etc/proxy/tun1.yaml &
      /usr/bin/hev-socks5-tunnel /etc/proxy/tun1.yaml &
    '';
  };

  uci = {
    settings = {
      https-dns-proxy = {
        https-dns-proxy = [
          {
            user = "nobody";
            group = "nogroup";
            listen_addr = "192.168.9.1";
            listen_port = 5055;
            bootstrap_dns = "1.1.1.1,1.0.0.1,2606:4700:4700::1111,2606:4700:4700::1001,8.8.8.8,8.8.4.4,9.9.9.9";
            resolver_url = "https://cloudflare-dns.com/dns-query";
            proxy_server = "socks5h://${service_ip}:7899";
          }
        ];
      };

      network = {
        interface = {
          tun1 = {
            proto = "none";
            device = "tun1";
            sourcefilter = false;
            defaultroute = false;
            delegate = false;
          };
        };
        route = [
          {
            interface = "tun1";
            target = "10.0.41.1/32";
          }
          {
            interface = "tun1";
            target = "0.0.0.0/0";
            table = 441;
          }
        ];
        route6 = [
          {
            interface = "tun1";
            target = "fd40::1/128";
          }
          {
            interface = "tun1";
            target = "::/0";
            table = 441;
          }
        ];
        rule = [{
          lookup = 441;
          mark = 441;
        }];
        rule6 = [{
          lookup = 441;
          mark = 441;
        }];
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "tun1" ];
}
