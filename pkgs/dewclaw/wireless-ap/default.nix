{ lib
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
    ../../../modules/openwrt/wireless.nix

    ./config.nix
  ];
}
