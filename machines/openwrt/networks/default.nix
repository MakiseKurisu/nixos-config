{
  imports = [
    ./lan.nix
    ./guest.nix
    ./wan.nix
    ./wwan.nix
    # ./wg0.nix
    ./wg1.nix
    # ./wg2.nix
    # ./wg3.nix
  ];

  uci = {
    settings = {
      network = {
        device = [
          {
            name = "br-lan";
            type = "bridge";
            ports = ["eth1" "lan1" "lan2" "lan3"];
          }
        ];
        bridge-vlan = [
          {
            device = "br-lan";
            vlan = 10;
            ports = ["eth1" "lan1:t"];
          }
          {
            device = "br-lan";
            vlan = 20;
            ports = ["lan1:t" "lan2" "lan3"];
          }
          {
            device = "br-lan";
            vlan = 30;
            ports = ["lan1:t"];
          }
        ];
      };
      firewall = {
        zone = [
          {
            name = "lan";
            network = [ "lan" ];
            input = "ACCEPT";
            output = "ACCEPT";
            forward = "ACCEPT";
          }
          {
            name = "wan";
            network = [ "wan" "wan6" "wwan" ];
            input = "DROP";
            output = "ACCEPT";
            forward = "DROP";
            masq = 1;
            mtu_fix = 1;
          }
          {
            name = "guest";
            network = [ "guest" ];
            input = "ACCEPT";
            output = "ACCEPT";
            forward = "ACCEPT";
          }
          {
            name = "wg";
            network = [ "wg0" "wg1" "wg2" "wg3" ];
            input = "ACCEPT";
            output = "ACCEPT";
            forward = "ACCEPT";
            masq = 1;
          }
        ];
        forwarding = [
          {
            src = "lan";
            dest = "wan";
          }
          {
            src = "lan";
            dest = "guest";
          }
          {
            src = "lan";
            dest = "wg";
          }
          {
            src = "guest";
            dest = "wan";
          }
          {
            src = "wg";
            dest = "lan";
          }
        ];
        rule = [
          # Default OpenWrt rules
          {
            dest_port = 68;
            family = "ipv4";
            name = "Allow-DHCP-Renew";
            proto = "udp";
            src = "wan";
            target = "ACCEPT";
          }
          {
            family = "ipv4";
            icmp_type = "echo-request";
            name = "Allow-Ping";
            proto = "icmp";
            src = "wan";
            target = "ACCEPT";
          }
          {
            family = "ipv4";
            name = "Allow-IGMP";
            proto = "igmp";
            src = "wan";
            target = "ACCEPT";
          }
          {
            dest_ip = "fc00::/6";
            dest_port = 546;
            family = "ipv6";
            name = "Allow-DHCPv6";
            proto = "udp";
            src = "wan";
            src_ip = "fc00::/6";
            target = "ACCEPT";
          }
          {
            family = "ipv6";
            icmp_type = [ "130/0" "131/0" "132/0" "143/0" ];
            name = "Allow-MLD";
            proto = "icmp";
            src = "wan";
            src_ip = "fe80::/10";
            target = "ACCEPT";
          }
          {
            family = "ipv6";
            icmp_type = [
              "echo-request"
              "echo-reply"
              "destination-unreachable"
              "packet-too-big"
              "time-exceeded"
              "bad-header"
              "unknown-header-type"
              "router-solicitation"
              "neighbour-solicitation"
              "router-advertisement"
              "neighbour-advertisement"
            ];
            limit = "1000/sec";
            name = "Allow-ICMPv6-Input";
            proto = "icmp";
            src = "wan";
            target = "ACCEPT";
          }
          {
            dest = "*";
            family = "ipv6";
            icmp_type = [
              "echo-request"
              "echo-reply"
              "destination-unreachable"
              "packet-too-big"
              "time-exceeded"
              "bad-header"
              "unknown-header-type"
            ];
            limit = "1000/sec";
            name = "Allow-ICMPv6-Forward";
            proto = "icmp";
            src = "wan";
            target = "ACCEPT";
          }
          {
            dest = "lan";
            name = "Allow-IPSec-ESP";
            proto = "esp";
            src = "wan";
            target = "ACCEPT";
          }
          {
            dest = "lan";
            dest_port = 500;
            name = "Allow-ISAKMP";
            proto = "udp";
            src = "wan";
            target = "ACCEPT";
          }
          {
            dest_port = "33434-33689";
            enabled = 0;
            family = "ipv4";
            name = "Support-UDP-Traceroute";
            proto = "udp";
            src = "wan";
            target = "REJECT";
          }
          # Custom rules
          {
            dest_port = 443;
            enabled = 0;
            name = "Block Guest Access";
            proto = "tcp";
            src = "guest";
            target = "DROP";
          }
          {
            dest = "lan";
            name = "Allow guest ping lan";
            proto = "icmp";
            src = "guest";
            target = "ACCEPT";
          }
          {
            name = "Ban hacker IP";
            src = "wan";
            src_ip = "185.137.36.69";
            target = "DROP";
          }
        ];
      };
    };
  };
}
