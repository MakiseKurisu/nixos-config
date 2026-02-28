{
  service_ip,
  ...
}:
{
  etc = {
    "proxy/tun0.yaml".text = ''
      tunnel:
        name: tun0
        mtu: 8500
        multi-queue: true
        ipv4: 10.0.40.1
        ipv6: "fd40::1"
      socks5:
        port: 7891
        address: ${service_ip}
        udp: udp
        mark: 438
    '';
    "rc.local".text = ''
      /usr/bin/hev-socks5-tunnel /etc/proxy/tun0.yaml &
      /usr/bin/hev-socks5-tunnel /etc/proxy/tun0.yaml &
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
            listen_port = 5054;
            bootstrap_dns = "1.1.1.1,1.0.0.1,2606:4700:4700::1111,2606:4700:4700::1001,8.8.8.8,8.8.4.4,9.9.9.9";
            resolver_url = "https://cloudflare-dns.com/dns-query";
            proxy_server = "socks5h://${service_ip}:7891";
          }
        ];
      };

      network = {
        interface = {
          tun0 = {
            proto = "none";
            device = "tun0";
            sourcefilter = false;
            defaultroute = false;
            delegate = false;
          };
        };
        route = [
          {
            interface = "tun0";
            target = "10.0.40.1/32";
          }
          {
            interface = "tun0";
            target = "0.0.0.0/0";
            table = 439;
          }
        ];
        route6 = [
          {
            interface = "tun0";
            target = "fd40::1/128";
          }
          {
            interface = "tun0";
            target = "::/0";
            table = 439;
          }
        ];
        rule = [
          {
            lookup = 439;
            mark = 439;
          }
        ];
        rule6 = [
          {
            lookup = 439;
            mark = 439;
            disabled = true;
          }
        ];
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "tun0" ];
}
