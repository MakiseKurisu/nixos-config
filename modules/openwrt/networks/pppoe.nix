# When OpenWrt is running from Incus, please add following configs:
#devices:
#  ppp:
#    mode: '0600'
#    path: /dev/ppp
#    required: 'false'
#    type: unix-char
{
  uci = {
    settings = {
      network = {
        interface = {
          pppoe = {
            device = "br-lan.10";
            proto = "pppoe";
            ipv6 = "auto";
            username._secret = "pppoe_username";
            password._secret = "pppoe_password";
            metric = 10;
            dns_metric = 10;
          };
        };
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "br-lan.10" ];
}
