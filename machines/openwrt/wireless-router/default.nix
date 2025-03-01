{ lib
, inputs
, release
, target
, arch
, hostname
, ip
, kver ? null
, ... }:

{
  imports = [
    (import ../../../modules/openwrt {
      inherit lib release target arch hostname ip kver;
    })
    (import ../../../modules/openwrt/router.nix {
      inherit arch;
    })
    (import ../../../modules/openwrt/proxy.nix {
      inherit lib;
      gfwlist2dnsmasq = inputs.gfwlist2dnsmasq;
    })
    ../../../modules/openwrt/dhcp.nix
    ../../../modules/openwrt/networks
    ../../../modules/openwrt/wireless.nix

    ./config.nix
  ];
}
