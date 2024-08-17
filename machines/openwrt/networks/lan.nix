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
        leasetime = "1h";
        ra_flags = "none";
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
