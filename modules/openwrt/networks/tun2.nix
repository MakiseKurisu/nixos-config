{
  service_ip,
  ...
}:
{
  etc = {
    "proxy/tun2.yaml".text = ''
      tunnel:
        name: tun2
        mtu: 8500
        multi-queue: true
        ipv4: 10.0.42.1
        ipv6: "fd42::1"
      socks5:
        port: 1080
        address: 10.0.21.1
        udp: udp
        mark: 436
    '';
    "rc.local".text = ''
      /usr/bin/hev-socks5-tunnel /etc/proxy/tun2.yaml &
      /usr/bin/hev-socks5-tunnel /etc/proxy/tun2.yaml &
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
            listen_port = 5053;
            bootstrap_dns = "1.1.1.1,1.0.0.1,2606:4700:4700::1111,2606:4700:4700::1001,8.8.8.8,8.8.4.4,9.9.9.9";
            resolver_url = "https://cloudflare-dns.com/dns-query";
            proxy_server = "socks5h://10.0.21.1:1080";
          }
        ];
      };

      network = {
        interface = {
          tun2 = {
            proto = "none";
            device = "tun2";
            sourcefilter = false;
            defaultroute = false;
            delegate = false;
          };
        };
        route = [
          {
            interface = "tun2";
            target = "10.0.42.1/32";
          }
          {
            interface = "tun2";
            target = "0.0.0.0/0";
            table = 440;
          }
        ];
        route6 = [
          {
            interface = "tun2";
            target = "fd42::1/128";
          }
          {
            interface = "tun2";
            target = "::/0";
            table = 440;
          }
        ];
        rule = [
          {
            lookup = 440;
            mark = 440;
          }
        ];
        rule6 = [
          {
            lookup = 440;
            mark = 440;
          }
        ];
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "tun2" ];
}
