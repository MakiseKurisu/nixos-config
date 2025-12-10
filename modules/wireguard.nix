{ config, lib, pkgs, ... }:

{
  networking = {
    wg-quick.interfaces = {
      wg0 = {
        address = [ "10.0.32.3/32" "fd32::3/128" ];
        dns = [ "10.0.32.1" ];
        mtu = 1280;
        privateKeyFile = "/var/lib/wireguard/wg0.key";

        peers = [
          {
            publicKey = "WVcdwHDpBQq2bg4bJE6zHRdWuPG7mptkuF48HxNFNw4=";

            allowedIPs = [
              "10.0.32.0/24"
              "fd32::/64"
              "192.168.2.0/24"
              "fd02::/64"
              "192.168.9.0/24"
              "fd09::/64"
              "10.0.20.0/24"
              "fd20::/64"
              "10.0.21.0/24"
              "fd21::/64"
            ];

            endpoint = "vamrs.vpndns.net:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
    wireguard = {
      useNetworkd = false;
      interfaces = {
        wg1 = {
          type = "amneziawg";
          privateKeyFile = "/var/lib/wireguard/wg0.key";
          mtu = 1280;
          listenPort = 51820;
          ips = [
            "10.0.20.2/32"
            "fd20::2/128"
          ];
          extraOptions = {
            Jc = 1;
            Jmin = 10;
            Jmax = 50;
            S1 = 16;
            S2 = 48;
          };
          dynamicEndpointRefreshSeconds = 5;
          peers = [
            {
              publicKey = "mM6UKv/6OJW0re4/R24TGnxhA5g+7XHIkM/iGCSR7Tk=";
              persistentKeepalive = 25;
              endpoint = "140.245.83.173:51820";
              allowedIPs = [
                "10.0.20.0/24"
                "fd20::/64"
              ];
            }
          ];
        };
      };
    };
  };
}
