{
  uci = {
    settings = {
      dropbear.dropbear = [
        {
          Interface = "wg3";
          PasswordAuth = "on";
          GatewayPorts = "on";
          RootPasswordAuth = "on";
          Port = 22;
        }
      ];
      network = {
        interface = {
          wg3 = {
            proto = "wireguard";
            addresses = [ "10.0.21.3/32" "fd21::3/128" ];
            mtu = 1280;
            private_key._secret = "wg3_private_key";
          };
        };
        wireguard_wg3 = [{
          allowed_ips = [ "10.0.21.0/24" "fd21::/64" ];
          description = "singapore";
          endpoint_host = "127.0.0.1";
          endpoint_port = 51818;
          public_key = "mM6UKv/6OJW0re4/R24TGnxhA5g+7XHIkM/iGCSR7Tk=";
          route_allowed_ips = 1;
          persistent_keepalive = 25;
        }];
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "wg3" ];
}
