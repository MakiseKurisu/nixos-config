{ lib
, gfwlist2dnsmasq
, release
, target
, arch
, hostname
, ip
, kver ? null
, service_ip
, ... }:

{
  imports = [
    (import ../../../modules/openwrt {
      inherit lib release target arch hostname ip kver;
    })
    (import ../../../modules/openwrt/router.nix {
      inherit arch release;
    })
    (import ../../../modules/openwrt/proxy.nix {
      inherit lib service_ip gfwlist2dnsmasq;
    })
    (import ../../../modules/openwrt/dhcp.nix {
      inherit service_ip;
    })
    (import ../../../modules/openwrt/networks {
      inherit service_ip;
    })

    ./config.nix
  ];
}
