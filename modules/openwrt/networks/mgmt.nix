{
  uci = {
    settings = {
      dhcp.dhcp.mgmt = {
        interface = "mgmt";
        start = 50;
        limit = 200;
        leasetime = "12h";
      };
      network = {
        interface = {
          mgmt = {
            device = "br-lan.40";
            proto = "static";
            ipaddr = "192.168.10.1/24";
            delegate = 0;
            ip6hint = 40;
            ip6assign = 64;
            ip6class = "local";
          };
        };
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "br-lan.40" ];
}
