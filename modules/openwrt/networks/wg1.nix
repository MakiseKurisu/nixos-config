{
  etc = {
    "wireguard/keep_alive".text = ''
      #!/usr/bin/env sh
      WG="$1"
      LATEST_HANDSHAKES="$(( $(date +%s) - $(wg show "$WG" latest-handshakes | cut -f2) ))"
      if [ $LATEST_HANDSHAKES -gt 180 ]; then
        ifdown "$WG"
        ifup "$WG"
      fi
    '';
    "crontabs/root".text = ''
      * * * * * sh /etc/wireguard/keep_alive wg1
    '';
  };

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
            "192.168.7.0/24"
            #"10.0.20.0/24"
            #"fd20::/64"
            #"10.0.21.0/24"
            #"fd21::/64"
          ];
          endpoint_host = "vamrs.vpndns.net";
          public_key = "WVcdwHDpBQq2bg4bJE6zHRdWuPG7mptkuF48HxNFNw4=";
          route_allowed_ips = 1;
          persistent_keepalive = 25;
        }];
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "wg1" ];
}
