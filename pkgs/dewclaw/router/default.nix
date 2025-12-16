{ lib
, release
, target
, arch
, hostname
, ip
, kver ? null
, service_ip
, inputs
, ... }:

{
  imports = [
    (import ../../../modules/openwrt {
      inherit lib release target arch hostname ip kver inputs;
    })
    (import ../../../modules/openwrt/router.nix {
      inherit arch release;
    })
    (import ../../../modules/openwrt/proxy.nix {
      inherit lib service_ip inputs;
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
