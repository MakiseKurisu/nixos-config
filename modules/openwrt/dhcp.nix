{ service_ip
, ...}:

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
            "/*.mcdn.bilivideo.cn/"
            "/*.szbdyd.com/"
          ];
          server = [
            "/vamrs.org/192.168.2.1"
            "/vpndns.net/192.99.42.52"
            service_ip
          ];
          rebind_domain = [
            "vamrs.org"
          ];
        }];
        domain = [
          {
            ip = service_ip;
            name = "apt";
          }
          {
            ip = service_ip;
            name = "aria";
          }
          {
            ip = service_ip;
            name = "dns";
          }
          {
            ip = service_ip;
            name = "jf";
          }
          {
            ip = service_ip;
            name = "proxy";
          }
          {
            ip = service_ip;
            name = "kms";
          }
          {
            ip = service_ip;
            name = "ha";
          }
          {
            ip = service_ip;
            name = "dls";
          }
          {
            ip = service_ip;
            name = "downloads";
          }
          {
            ip = service_ip;
            name = "pico";
          }
        ];
        host = [
          {
            dns = true;
            ip = "192.168.9.2";
            mac = "5A:95:F9:90:E8:AF";
            name = "app01";
          }
          {
            dns = true;
            ip = "192.168.9.3";
            mac = "de:e6:f8:67:fa:fb";
            name = "nas";
          }
          {
            dns = true;
            ip = "192.168.9.10";
            mac = "C4:41:1E:F8:17:7E";
            name = "rt3200";
          }
          {
            dns = true;
            ip = "ignore";
            mac = "70:85:c2:bf:37:bc";
            name = "main-wol";
          }
          {
            dns = true;
            ip = "192.168.9.20";
            mac = "82:A0:F6:24:4C:88";
            name = "main";
          }
          {
            dns = true;
            ip = "192.168.9.21";
            mac = "52:54:00:D7:BF:CA";
            name = "windows";
          }
          {
            dns = true;
            ip = "192.168.9.22";
            mac = "BC:24:11:14:BD:88";
            name = "guest";
          }
        ];
      };
    };
  };
}
