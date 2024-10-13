{ lib
, inputs
, release
, target
, arch
, hostname
, ip
, ... }:

{
  imports = [
    (import ../../modules/openwrt {
      inherit lib release target arch hostname ip;
    })
    (import ../../modules/openwrt/router.nix {
      inherit arch;
    })
    (import ../../modules/openwrt/proxy.nix {
      inherit lib;
      gfwlist2dnsmasq = inputs.gfwlist2dnsmasq;
    })
    ../../modules/openwrt/dhcp.nix
    ../../modules/openwrt/networks
    ../../modules/openwrt/wireless.nix
  ];
}
