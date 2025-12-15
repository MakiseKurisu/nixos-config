{
  uci = {
    settings = {
      dropbear.dropbear = [
        {
          Interface = "wg2";
          PasswordAuth = "on";
          GatewayPorts = "on";
          RootPasswordAuth = "on";
          Port = 22;
        }
      ];
      network = {
        interface = {
          wg2 = {
            proto = "amneziawg";
            private_key._secret = "wg2_private_key";
            addresses = [ "10.0.20.3/32" "fd20::3/128" ];
            mtu = 1280;
            awg_jc = 1;
            awg_jmin = 10;
            awg_jmax = 50;
            awg_s1 = 16;
            awg_s2 = 48;
            sourcefilter = false;
            defaultroute = false;
          };
        };
        amneziawg_wg2 = [{
          description = "japan";
          public_key = "mM6UKv/6OJW0re4/R24TGnxhA5g+7XHIkM/iGCSR7Tk=";
          allowed_ips = [ "0.0.0.0/0" "::/0" ];
          route_allowed_ips = true;
          endpoint_host = "140.245.83.173";
          persistent_keepalive = 25;
        }];
        route = [
          {
            interface = "wg2";
            target = "10.0.20.0/24";
          }
          {
            interface = "wg2";
            target = "0.0.0.0/0";
            table = 440;
          }
        ];
        route6 = [
          {
            interface = "wg2";
            target = "fd20::/64";
          }
          {
            interface = "wg2";
            target = "::/0";
            table = 440;
          }
        ];
        rule = [{
          lookup = 440;
          mark = 440;
        }];
        rule6 = [{
          lookup = 440;
          mark = 440;
        }];
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "wg2" ];
}
