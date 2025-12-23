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
        51820 # amneziawg
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
              name = "mac";
              publicKey = "NaKi5MmgIfiul+zfZQHih8PBDqAuhCxO8x+4r+LAwDI=";
              allowedIPs = [
                "10.0.20.2/32"
                "fd20::2/128"
                "192.168.2.0/24"
              ];
            }
            {
              name = "router";
              publicKey = "T8RsOpzg6HInLTcQA9uev95KPZohQ2GE7JZv84Q2QTk=";
              allowedIPs = [
                "10.0.20.3/32"
                "fd20::3/128"
                "192.168.9.0/24"
              ];
            }
            {
              name = "mobile";
              publicKey = "Et0MX62lSW2kHZgkaU3v9qmQVDMbam9MO+yFNW1w6jM=";
              allowedIPs = [
                "10.0.20.4/32"
                "fd20::4/128"
              ];
            }
            {
              name = "laptop";
              publicKey = "5Ij1PKM4T9dL8JSmIb4m0lav09fibjbuM7Dj6oHHMiw=";
              allowedIPs = [
                "10.0.20.5/32"
                "fd20::5/128"
              ];
            }
            {
              name = "remote";
              publicKey = "fd1I/FnpKyEvqXjuVhoic4lCxU9r7zvP893m3Y6qPXo=";
              allowedIPs = [
                "10.0.20.6/32"
                "fd20::6/128"
                "192.168.10.0/24"
              ];
            }
          ];
        };
      };
    };
  };
}
