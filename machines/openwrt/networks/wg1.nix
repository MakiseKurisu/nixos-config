{
  uci = {
    settings = {
      dropbear.dropbear = [
        {
          Interface = "wg1";
          PasswordAuth = "on";
          GatewayPorts = "on";
          RootPasswordAuth = "on";
          Port = 22;
        }
      ];
      network = {
        interface = {
          wg1 = {
            proto = "wireguard";
            addresses = [ "10.0.32.6/32" "fd32::6/128" ];
            mtu = 1280;
            private_key._secret = "wg1_private_key";
          };
        };
        wireguard_wg1 = [{
          description = "vamrs";
          allowed_ips = [
            "10.0.32.0/24"
            "fd32::/64"
            "192.168.2.0/24"
            "fd02::/64"
            "192.168.3.0/24"
            "192.168.5.0/24"
            "192.168.31.0/24"
            "10.0.20.0/24"
            "fd20::/64"
            "10.0.21.0/24"
            "fd21::/64"
          ];
          endpoint_host = "vamrs.vpndns.net";
          persistent_keepalive = 25;
          public_key = "WVcdwHDpBQq2bg4bJE6zHRdWuPG7mptkuF48HxNFNw4=";
          route_allowed_ips = 1;
        }];
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "wg1" ];
}
