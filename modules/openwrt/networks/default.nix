{ service_ip
, ...}:

{
  imports = [
    (import ./lan.nix {
      inherit service_ip;
    })
    ./guest.nix
    ./mgmt.nix
    ./wan.nix
    ./wwan0.nix
    ./pppoe.nix
    ./tun.nix
    # ./wg0.nix
    ./wg1.nix
    ./wg2.nix
    ./wg3.nix
    ./wg4.nix
  ];

  uci = {
    settings = {
      firewall = {
        zone = [
          {
            name = "lan";
            network = [ "lan" "lan6" ];
            input = "ACCEPT";
            output = "ACCEPT";
            forward = "ACCEPT";
            masq = true;
          }
          {
            name = "wan";
            network = [ "wan" "wan6" "wwan0" "pppoe" ];
            input = "DROP";
            output = "ACCEPT";
            forward = "DROP";
            masq = true;
            mtu_fix = true;
          }
          {
            name = "guest";
            network = [ "guest" ];
            input = "ACCEPT";
            output = "ACCEPT";
            forward = "ACCEPT";
          }
          {
            name = "mgmt";
            network = [ "mgmt" ];
            input = "ACCEPT";
            output = "ACCEPT";
            forward = "DROP";
          }
          {
            name = "wg";
            network = [ "wg0" "wg1" "wg2" "wg3" "wg4" "tun0" ];
            input = "ACCEPT";
            output = "ACCEPT";
            forward = "ACCEPT";
            masq = true;
            masq6 = true;
          }
        ];
        forwarding = [
          {
            src = "lan";
            dest = "mgmt";
          }
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
            name = "Disable-UDP-Traceroute";
            proto = "udp";
            src = "wan";
            target = "REJECT";
          }
          # Custom rules
          {
            dest_port = 443;
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
          {
            name = "Allow WAN SSH";
            enabled = false;
            proto = "tcp";
            src = "wan";
            dest_port = 22;
            target = "ACCEPT";
          }
        ];
      };
    };
  };
}
