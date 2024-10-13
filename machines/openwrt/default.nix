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
    # This file cannot contain UCI configuration when merged with another attrset
    # in flake.nix, as those settings will not presist.
    # Create a new file to keep those
    ./generic.nix
  ];
}
