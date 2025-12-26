{
  uci = {
    settings = {
      dhcp.dhcp.guest = {
        interface = "guest";
        start = 50;
        limit = 200;
        leasetime = "12h";
      };
      network = {
        interface = {
          guest = {
            device = "br-lan.30";
            proto = "static";
            ipaddr = "192.168.8.1/24";
            delegate = 0;
            ip6hint = 30;
            ip6assign = 64;
            ip6class = "local";
            arp_accept = true;
          };
        };
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "br-lan.30" ];
}
