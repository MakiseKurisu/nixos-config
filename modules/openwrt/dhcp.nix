{
  uci = {
    settings = {
      dhcp = {
        dnsmasq = [{
          authoritative = 1;
          confdir = "/etc/dnsmasq.d";
          domain = "protoducer.com";
          local = "/protoducer.com/";
          domainneeded = 1;
          leasefile = "/tmp/dhcp.leases";
          rebind_localhost = 1;
          rebind_protection = 1;
          localservice = 1;
          localise_queries = 1;
          expandhosts = 1;
          readethers = 1;
          dnsforwardmax = 1000;
          cachesize = 10000;
          address = [
            "/time.android.com/203.107.6.88"
          ];
          server = [
            "/vamrs.org/192.168.2.1"
            "/bilivideo.cn/119.29.29.29"
            "/bilivideo.com/119.29.29.29"
            "/hdslb.com/119.29.29.29"
            "/bilibili.com/119.29.29.29"
          ];
          rebind_domain = [
            "vamrs.org"
          ];
        }];
      };
    };
  };
}
