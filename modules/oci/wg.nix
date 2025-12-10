{ inputs, config, lib, pkgs, ... }:

{
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      amneziawg
    ];
  };

  networking = {
    firewall = {
      allowedUDPPorts = [
        51820 #amneziawg
      ];
    };

    wireguard = {
      useNetworkd = false;
      interfaces = {
        wg0 = {
          type = "amneziawg";
          privateKeyFile = "/var/lib/wireguard/wg0.key";
          mtu = 1280;
          listenPort = 51820;
          ips = [
            "10.0.20.1/24"
            "fd20::1/64"
          ];
          extraOptions = {
            Jc = 1;
            Jmin = 10;
            Jmax = 50;
            S1 = 16;
            S2 = 48;
          };
          peers = [
            {
              publicKey = "NaKi5MmgIfiul+zfZQHih8PBDqAuhCxO8x+4r+LAwDI=";
              allowedIPs = [
                "10.0.20.2/32"
                "fd20::2/128"
              ];
            }
            {
              publicKey = "T8RsOpzg6HInLTcQA9uev95KPZohQ2GE7JZv84Q2QTk=";
              allowedIPs = [
                "10.0.20.3/32"
                "fd20::3/128"
              ];
            }
          ];
        };
      };
    };
  };
}
