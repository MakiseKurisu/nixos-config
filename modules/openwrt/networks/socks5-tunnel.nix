{
  tun_name,
  subnet,
  proxy_ip,
  proxy_port,
  proxy_mark,
  dns_port,
  route_mark,
  ...
}:
{
  etc = {
    "proxy/${tun_name}.yaml".text = ''
      tunnel:
        name: ${tun_name}
        mtu: 8500
        multi-queue: true
        ipv4: 10.0.${toString subnet}.1
        ipv6: "fd${toString subnet}::1"
      socks5:
        port: ${toString proxy_port}
        address: ${proxy_ip}
        udp: udp
        mark: ${toString proxy_mark}
    '';
    "rc.local".text = ''
      /usr/bin/hev-socks5-tunnel /etc/proxy/${tun_name}.yaml &
      /usr/bin/hev-socks5-tunnel /etc/proxy/${tun_name}.yaml &
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
            listen_port = dns_port;
            bootstrap_dns = "1.1.1.1,1.0.0.1,2606:4700:4700::1111,2606:4700:4700::1001,8.8.8.8,8.8.4.4,9.9.9.9";
            resolver_url = "https://cloudflare-dns.com/dns-query";
            proxy_server = "socks5h://${proxy_ip}:${toString proxy_port}";
          }
        ];
      };

      network = {
        interface = {
          "${tun_name}" = {
            proto = "none";
            device = tun_name;
            sourcefilter = false;
            defaultroute = false;
            delegate = false;
          };
        };
        route = [
          {
            interface = tun_name;
            target = "10.0.${toString subnet}.1/32";
          }
          {
            interface = tun_name;
            target = "0.0.0.0/0";
            table = route_mark;
          }
        ];
        route6 = [
          {
            interface = tun_name;
            target = "fd${toString subnet}::1/128";
          }
          {
            interface = tun_name;
            target = "::/0";
            table = route_mark;
          }
        ];
        rule = [
          {
            lookup = route_mark;
            mark = route_mark;
          }
        ];
        rule6 = [
          {
            lookup = route_mark;
            mark = route_mark;
            disabled = true;
          }
        ];
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ tun_name ];
}
