{
  uci = {
    settings = {
      network = {
        interface = {
          wan = {
            device = "br-lan.10";
            proto = "dhcp";
          };
          wan6 = {
            device = "br-lan.10";
            proto = "dhcpv6";
            reqaddress = "try";
            reqprefix = "auto";
          };
        };
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "br-lan.10" ];
}
