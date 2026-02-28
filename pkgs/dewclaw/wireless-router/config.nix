{
  uci = {
    settings = {
      network = {
        device = [
          {
            name = "br-lan";
            type = "bridge";
            ports = [
              "eth1"
              "lan1"
              "lan2"
              "lan3"
              "lan4"
              "wan"
            ];
            stp = 1;
          }
        ];
        bridge-vlan = [
          {
            device = "br-lan";
            vlan = 10;
            ports = [
              "eth1"
              "lan1:t"
              "lan2:t"
              "wan"
            ];
          }
          {
            device = "br-lan";
            vlan = 20;
            ports = [
              "lan1:t"
              "lan2:t"
              "lan3"
              "lan4"
            ];
          }
          {
            device = "br-lan";
            vlan = 30;
            ports = [
              "lan1:t"
              "lan2:t"
            ];
          }
        ];
      };
    };
  };
}
