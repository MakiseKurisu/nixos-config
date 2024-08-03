{ lib
, inputs
, release ? "23.05.4"
, target ? "mediatek/mt7622"
, arch ? "aarch64_cortex-a53"
, hostname ? "OpenWrt"
, ip ? "192.168.9.1"
, ... }:

{
  uci = {
    settings = {
      network = {
        globals.globals = {
          ula_prefix = "fd09::/48";
        };
      };
    };
  };
}
