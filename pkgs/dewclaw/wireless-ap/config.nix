{
  uci = {
    settings = {
      dropbear.dropbear = [
        {
          Interface = "lan";
          PasswordAuth = "on";
          GatewayPorts = "on";
          RootPasswordAuth = "on";
          Port = 22;
        }
        {
          Interface = "lan6";
          PasswordAuth = "on";
          GatewayPorts = "on";
          RootPasswordAuth = "on";
          Port = 22;
        }
      ];
      firewall = {
        zone = [
          {
            name = "lan";
            network = [
              "lan"
              "lan6"
            ];
            input = "ACCEPT";
            output = "ACCEPT";
            forward = "ACCEPT";
          }
        ];
      };
      network = {
        device = [
          {
            name = "br-lan";
            type = "bridge";
            ports = [
              "eth1"
              "lan1"
              "lan2"
              "lan3"
              "lan4"
              "wan"
            ];
            stp = 1;
          }
        ];
        bridge-vlan = [
          {
            device = "br-lan";
            vlan = 10;
            ports = [
              "eth1"
              "lan1:t"
              "lan2:t"
              "wan"
            ];
          }
          {
            device = "br-lan";
            vlan = 20;
            ports = [
              "lan1:t"
              "lan2:t"
              "lan3"
              "lan4"
            ];
          }
          {
            device = "br-lan";
            vlan = 30;
            ports = [
              "lan1:t"
              "lan2:t"
            ];
          }
        ];
        interface = {
          wan = {
            device = "br-lan.10";
            proto = "none";
          };
          lan = {
            device = "br-lan.20";
            proto = "dhcp";
          };
          lan6 = {
            device = "br-lan.20";
            proto = "dhcpv6";
            reqaddress = "try";
            reqprefix = "auto";
          };
          guest = {
            device = "br-lan.30";
            proto = "none";
          };
        };
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [
    "br-lan.10"
    "br-lan.20"
    "br-lan.30"
  ];
}
