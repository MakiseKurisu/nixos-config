{ config, lib, pkgs, ... }:

{
  networking = {
    wg-quick.interfaces = {
      wg0 = {
        address = [ "10.0.32.3/32" "fd32::3/128" ];
        dns = [ "10.0.32.1" ];
        mtu = 1280;
        privateKeyFile = config.sops.secrets.p15_private_key.path;

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
      interfaces = {
        wg2 = {
          privateKeyFile = config.sops.secrets.p15_private_key.path;
          ips = [
            "10.0.20.5/32"
            "fd20::5/128"
          ];
        };
      };
    };
  };
}
