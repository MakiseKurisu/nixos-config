{
  uci = {
    settings = {
      network = {
        interface = {
          pppoe = {
            device = "br-lan.10";
            proto = "pppoe";
            ipv6 = "auto";
            username._secret = "pppoe_username";
            password._secret = "pppoe_password";
            metric = 10;
            dns_metric = 10;
            auto = false;
          };
        };
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "br-lan.10" ];
}
