{ config, lib, pkgs, ... }:

{
  networking = {
    #nameservers = lib.mkBefore [ "192.168.11.1" "fd11::1" "114.114.114.114" ];
    wireguard.interfaces = {
      /*
      wg0 = {
        ips = [ "10.0.1.10/32" "fd01::10/128" ];
        mtu = 1280;
        privateKeyFile = "/home/excalibur/wireguard/wg0.key";

        peers = [
          {
            publicKey = "Incx4TYB5iWaao0gHSsUlUSGxHF4ItiaspZexMa8v30=";

            allowedIPs = [ 
              "10.0.1.0/24"
              "fd01::/64"
              "192.168.11.0/24"
              "fd11::/64"
            ];

            endpoint = "protoducer-cn-wuh.64-b.it:51820";
            persistentKeepalive = 25;
          }
        ];
      };
      */
      wg1 = {
        ips = [ "10.0.32.3/32" "fd32::3/128" ];
        mtu = 1280;
        privateKeyFile = "/home/excalibur/wireguard/wg1.key";

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
      /*
      wg2 = {
        ips = [ "10.0.20.4/32" "fd20::4/128" ];
        mtu = 1280;
        privateKeyFile = "/home/excalibur/wireguard/wg2.key";

        peers = [
          {
            publicKey = "WVcdwHDpBQq2bg4bJE6zHRdWuPG7mptkuF48HxNFNw4=";
            allowedIPs = [
              "10.0.20.0/24"
              "fd20::/64"
            ];

            endpoint = "vamrs.vpndns.net:51820";
            persistentKeepalive = 25;
          }
        ];
      };
      */
    };
  };
}
