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
            proto = "wireguard";
            addresses = [ "10.0.20.3/32" "fd20::3/128" ];
            mtu = 1280;
            private_key._secret = "wg2_private_key";
          };
        };
        wireguard_wg2 = [{
          allowed_ips = [ "10.0.20.0/24" "fd20::/64" ];
          description = "japan";
          endpoint_host = "127.0.0.1";
          endpoint_port = 51819;
          public_key = "mM6UKv/6OJW0re4/R24TGnxhA5g+7XHIkM/iGCSR7Tk=";
          route_allowed_ips = 1;
          persistent_keepalive = 25;
        }];
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "wg2" ];
}
