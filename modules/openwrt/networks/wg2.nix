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
          };
        };
        amneziawg_wg2 = [{
          description = "japan";
          public_key = "mM6UKv/6OJW0re4/R24TGnxhA5g+7XHIkM/iGCSR7Tk=";
          allowed_ips = [ "10.0.20.0/24" "fd20::/64" ];
          route_allowed_ips = true;
          endpoint_host = "155.248.160.18";
          persistent_keepalive = 25;
        }];
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "wg2" ];
}
