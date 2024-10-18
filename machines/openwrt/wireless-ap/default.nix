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
    (import ../../../modules/openwrt {
      inherit lib release target arch hostname ip;
    })
    ../../../modules/openwrt/wireless.nix

    ./config.nix
  ];
}
