{
  packages = [
    "hev-socks5-tunnel"
  ];

  etc = {
    "proxy/postup".text = ''
      #!/usr/bin/env sh

      nft "add chain inet fw4 accept_to_tun"
      nft 'add rule inet fw4 accept_to_tun oifname { tun0 } counter accept comment "!fw4: accept tun IPv4/IPv6 traffic"'
      nft 'add rule inet fw4 forward_lan counter jump accept_to_tun'
    '';
    "proxy/tun0.yaml".text = ''
      tunnel:
        name: tun0
        mtu: 8500
        multi-queue: true
        ipv4: 10.0.40.1
        ipv6: "fd40::1"
      socks5:
        port: 7891
        address: 192.168.9.3
        udp: udp
        mark: 438
    '';
    "rc.local".text = ''
      chmod +x /etc/proxy/postup
    '';
  };

  uci = {
    settings = {
      hev-socks5-tunnel = {
        hev-socks5-tunnel.config = {
          enabled = true;
          conffile = "/etc/proxy/tun0.yaml";
        };
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
        rule = [{
          lookup = 439;
          mark = 439;
        }];
        rule6 = [{
          lookup = 439;
          mark = 439;
        }];
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "tun0" ];
}
