{ lib
, release
, target
, arch
, hostname
, ip
, kver ? null
, inputs
, ... }:

{
  imports = [
    (import ../../../modules/openwrt {
      inherit lib release target arch hostname ip kver inputs;
    })
    ../../../modules/openwrt/wireless.nix

    ./config.nix
  ];
}
