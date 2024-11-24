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
            "/vpndns.net/192.99.42.52"
            "192.168.9.2"
          ];
          rebind_domain = [
            "vamrs.org"
          ];
        }];
        domain = [
          {
            ip = "192.168.9.2";
            name = "apt";
          }
          {
            ip = "192.168.9.2";
            name = "aria";
          }
          {
            ip = "192.168.9.2";
            name = "dns";
          }
          {
            ip = "192.168.9.2";
            name = "jf";
          }
          {
            ip = "192.168.9.2";
            name = "proxy";
          }
          {
            ip = "192.168.9.2";
            name = "kms";
          }
          {
            ip = "192.168.9.2";
            name = "ha";
          }
          {
            ip = "192.168.9.2";
            name = "dls";
          }
        ];
        host = [
          {
            dns = 1;
            ip = "192.168.9.2";
            mac = "82:53:68:47:ac:ef";
            name = "app01";
          }
          {
            dns = 1;
            ip = "192.168.9.3";
            mac = "82:fb:e4:27:5e:1a";
            name = "nas";
          }
          {
            dns = 1;
            ip = "192.168.9.10";
            mac = "C4:41:1E:F8:17:7E";
            name = "rt3200";
          }
          {
            dns = 1;
            ip = "192.168.9.12";
            mac = "70:85:c2:bf:37:bc";
            name = "pve12";
          }
          {
            dns = 1;
            ip = "192.168.9.20";
            mac = "e2:7d:42:40:69:67";
            name = "main";
          }
          {
            dns = 1;
            ip = "192.168.9.21";
            mac = "1E:48:94:FD:07:2B";
            name = "windows";
          }
          {
            ip = "192.168.9.22";
            mac = "BC:24:11:14:BD:88";
            name = "guest";
          }
        ];
      };
    };
  };
}
