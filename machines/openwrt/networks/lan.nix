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
      ];
      dhcp.dhcp.lan = {
        interface = "lan";
        start = 100;
        limit = 250;
        leasetime = "12h";
        ra_flags = "none";
      };
      firewall = {
        redirect = [
          {
            name = "aria2-wan";
            target = "DNAT";
            src = "wan";
            src_dport = 6888;
            dest = "lan";
            dest_ip = "192.168.9.2";
            dest_port = 6888;
          }
          {
            name = "aria2-wg";
            target = "DNAT";
            src = "wg";
            src_dport = 6888;
            dest = "lan";
            dest_ip = "192.168.9.2";
            dest_port = 6888;
          }
        ];
      };
      network = {
        interface = {
          lan = {
            device = "br-lan.20";
            proto = "static";
            ipaddr = "192.168.9.1/24";
            ip6assign = 64;
          };
        };
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "br-lan.20" ];
}
