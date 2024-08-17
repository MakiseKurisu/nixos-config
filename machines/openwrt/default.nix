{ lib
, inputs
, release ? "23.05.4"
, target ? "mediatek/filogic"
, arch ? "aarch64_cortex-a53"
, hostname ? "OpenWrt"
, ip ? "192.168.2.101"
, ... }:

{
  imports = [
    (import ../../modules/openwrt {
      inherit release target arch hostname ip;
    })
    (import ../../modules/openwrt/router.nix {
      inherit arch;
    })
    (import ../../modules/openwrt/proxy.nix {
      inherit lib;
      gfwlist2dnsmasq = inputs.gfwlist2dnsmasq;
    })
    ../../modules/openwrt/dhcp.nix

    ./dhcp.nix
    ./networks
    ./wireless.nix
  ];

  etc = {
    "proxy/gfwlist.conf".text = lib.readFile ./gfwlist.conf;
    "proxy/blocklist.conf".text = lib.readFile ./blocklist.conf;
  };
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
            dev = "br-lan.10";
            mode = "rx";
          }
          {
            name = "Transmit";
            sysfs = "green:status";
            trigger = "netdev";
            dev = "br-lan.10";
            mode = "tx";
          }
        ];
      };
    };
  };
}
