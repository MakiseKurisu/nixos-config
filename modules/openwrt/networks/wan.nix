{
  uci = {
    settings = {
      dropbear.dropbear = [
        {
          Interface = "wan";
          PasswordAuth = "off";
          GatewayPorts = "on";
          RootPasswordAuth = "off";
          Port = 22;
        }
        {
          Interface = "wan6";
          PasswordAuth = "off";
          GatewayPorts = "on";
          RootPasswordAuth = "off";
          Port = 22;
        }
      ];
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
