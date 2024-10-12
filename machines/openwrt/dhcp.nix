{
  uci = {
    settings = {
      dhcp = {
        domain = [
          {
            ip = "192.168.9.2";
            name = "yacd";
          }
          {
            ip = "192.168.9.2";
            name = "qbit";
          }
          {
            ip = "192.168.9.2";
            name = "npm";
          }
          {
            ip = "192.168.9.2";
            name = "apt";
          }
          {
            ip = "192.168.9.2";
            name = "jf";
          }
        ];
        host = [
          {
            dns = 1;
            ip = "192.168.9.2";
            mac = "BC:24:11:69:19:E6";
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
            ip = "192.168.9.11";
            mac = "2c:53:4a:04:00:32";
            name = "pve11";
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
            mac = "26:4b:48:e9:08:62";
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
