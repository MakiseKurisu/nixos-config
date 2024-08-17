{
  uci = {
    settings = {
      dropbear.dropbear = [
        {
          Interface = "wg0";
          PasswordAuth = "on";
          GatewayPorts = "on";
          RootPasswordAuth = "on";
          Port = 22;
        }
      ];
      network = {
        interface = {
          wg0 = {
            proto = "wireguard";
            addresses = [ "10.0.1.1/24" "fd01::1/64" ];
            listen_port = 51820;
            mtu = 1280;
            private_key._secret = "wg0_private_key";
          };
        };
        wireguard_wg0 = [];
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "wg0" ];
}
