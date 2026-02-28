{
  uci = {
    settings = {
      dropbear.dropbear = [
        {
          Interface = "wg4";
          PasswordAuth = "on";
          GatewayPorts = "on";
          RootPasswordAuth = "on";
          Port = 22;
        }
      ];
      network = {
        interface = {
          wg4 = {
            proto = "wireguard";
            addresses = [
              "10.1.0.2/32"
              "fdbe::2/128"
            ];
            mtu = 1280;
            private_key._secret = "wg4_private_key";
          };
        };
        wireguard_wg4 = [
          {
            allowed_ips = [
              "10.1.0.1/32"
              "fdbe::1/128"
            ];
            description = "breadro";
            endpoint_host = "breadro.com";
            public_key = "A1Q1YBomxVI8r+hrHcw667WsOCqhkeKXX17YkbpQWn0=";
            route_allowed_ips = 1;
          }
          {
            allowed_ips = [
              "10.1.0.4/32"
              "fdbe::4/128"
            ];
            description = "sh.breadro";
            endpoint_host = "sh.breadro.com";
            public_key = "5FmrArolI4v240v5MnMA7XmYXjSFDmIhtT3GmmxKwiY=";
            route_allowed_ips = 1;
          }
        ];
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "wg4" ];
}
