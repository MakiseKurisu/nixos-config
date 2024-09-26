{
  uci = {
    sopsSecrets = ./secrets.yaml;

    settings = {
      network = {
        globals.globals = {
          ula_prefix = "fd09::/48";
        };
      };

      system = {
        led = [
          {
            name = "Receive";
            sysfs = "red:status";
            trigger = "netdev";
            dev = "wwan0";
            mode = "rx";
          }
          {
            name = "Transmit";
            sysfs = "green:status";
            trigger = "netdev";
            dev = "wwan0";
            mode = "tx";
          }
          {
            name = "Receive";
            sysfs = "inet:orange";
            trigger = "netdev";
            dev = "wwan0";
            mode = "rx";
          }
          {
            name = "Transmit";
            sysfs = "inet:blue";
            trigger = "netdev";
            dev = "wwan0";
            mode = "tx";
          }
          {
            name = "Power";
            sysfs = "power:blue";
            trigger = "default-on";
          }
          {
            name = "Status";
            sysfs = "power:orange";
            trigger = "heartbeat";
          }
        ];
      };
    };
  };
}
