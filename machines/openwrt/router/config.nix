{
  uci = {
    settings = {
      network = {
        device = [
          {
            name = "br-lan";
            type = "bridge";
            ports = ["eth0"];
          }
        ];
        bridge-vlan = [
          {
            device = "br-lan";
            vlan = 10;
            ports = ["eth0:t"];
          }
          {
            device = "br-lan";
            vlan = 20;
            ports = ["eth0:t"];
          }
          {
            device = "br-lan";
            vlan = 30;
            ports = ["eth0:t"];
          }
        ];
      };
    };
  };
}
