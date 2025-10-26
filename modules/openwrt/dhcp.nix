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
            name = "mc";
          }
          {
            ip = service_ip;
            name = "nc";
          }
          {
            ip = service_ip;
            name = "ol";
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
            ip = "192.168.9.11";
            mac = "8C:DE:F9:B4:37:A9";
            name = "ax3600";
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
          {
            dns = true;
            ip = "192.168.9.23";
            mac = "e2:2b:e4:b8:0f:52";
            name = "p15";
          }
          {
            dns = true;
            ip = "192.168.8.3";
            mac = "de:e6:f8:67:fa:fb";
            name = "nas";
          }
          {
            dns = true;
            ip = "192.168.8.4";
            mac = "C0:18:03:E9:1C:B9";
            name = "HPE91CB9";
          }
          {
            dns = true;
            ip = "192.168.8.10";
            mac = "30:83:98:a1:bf:ba";
            name = "ESP_A1BFBA";
          }
          {
            dns = true;
            ip = "192.168.8.11";
            mac = "C4:5B:BE:D9:3E:F1";
            name = "ESP_D93EF1";
          }
          {
            dns = true;
            ip = "192.168.8.15";
            mac = "84:7C:9B:7A:10:3B";
            name = "QCA4002";
          }
          {
            dns = true;
            ip = "192.168.8.16";
            mac = "a4:7d:9f:eb:a8:c8";
            name = "Ipcamera";
          }
          {
            dns = true;
            ip = "192.168.8.20";
            mac = "7C:C2:94:E8:F1:1F";
            name = "lumi.acpartner.mcn04";
          }
          {
            dns = true;
            ip = "192.168.8.21";
            mac = "54:EF:44:4F:24:78";
            name = "lumi.gateway.mcn001";
          }
          {
            dns = true;
            ip = "192.168.8.22";
            mac = "64:9E:31:67:0D:AD";
            name = "qmi.plug.psv3.fan";
          }
          {
            dns = true;
            ip = "192.168.8.23";
            mac = "D4:F0:EA:C5:7B:A7";
            name = "qmi.plug.psv3.dehumidifier";
          }
          {
            dns = true;
            ip = "192.168.8.24";
            mac = "44:23:7C:A9:47:8F";
            name = "chunmi.ihcooker.chefnic";
          }
          {
            dns = true;
            ip = "192.168.8.25";
            mac = "7C:C2:94:BF:05:98";
            name = "chunmi.waterpuri.800f3p";
          }
          {
            dns = true;
            ip = "192.168.8.26";
            mac = "EC:4D:3E:D5:30:DF";
            name = "lumi.curtain.hmcn02";
          }
          {
            dns = true;
            ip = "192.168.8.27";
            mac = "5C:02:14:28:39:1B";
            name = "xiaomi.wifispeaker.l16a";
          }
        ];
      };
    };
  };
}
