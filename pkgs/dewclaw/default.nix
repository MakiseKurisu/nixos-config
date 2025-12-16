{ lib
, inputs
, ...
}:

{
  configuration = {
    openwrt = {
      rax3000m = import ./wireless-router {
        inherit lib inputs;
        release = "23.05.5";
        target = "mediatek/filogic";
        arch = "aarch64_cortex-a53";
        hostname = "RAX3000M";
        ip = "192.168.9.1";
        service_ip = "192.168.9.3";
      } // {
        uci.settings.wireless.wifi-device.radio0.path = "platform/18000000.wifi";
        uci.settings.wireless.wifi-device.radio1.path = "platform/18000000.wifi+1";
      };
      rt3200 = import ./wireless-ap {
        inherit lib inputs;
        release = "24.10.2";
        target = "mediatek/mt7622";
        arch = "aarch64_cortex-a53";
        hostname = "RT3200";
        ip = "192.168.9.10";
        kver = "6.6.93-1-afd40c8eeeeb9c2687b86b1756cbcd8d";
      } // {
        uci.settings.wireless.wifi-device.radio0.path = "platform/18000000.wmac";
        uci.settings.wireless.wifi-device.radio1.path = "1a143000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0";
      };
      openwrt = import ./router {
        inherit lib inputs;
        release = "24.10.2";
        target = "x86/64";
        arch = "x86_64";
        hostname = "OpenWrt";
        ip = "192.168.9.1";
        kver = "6.6.93-1-1745ebad77278f5cdc8330d17a3f43d6";
        service_ip = "192.168.9.3";
      };
      m93p = import ./router {
        inherit lib inputs;
        release = "23.05.5";
        target = "x86/64";
        arch = "x86_64";
        hostname = "M93p";
        ip = "192.168.9.1";
        service_ip = "192.168.9.3";
      } // {
        packages = [
          "kmod-iwlwifi"
          "iwlwifi-firmware-iwl7260"
          "kmod-r8169"
          "r8169-firmware"
        ];
      };
      p15 = import ./router {
        inherit lib inputs;
        release = "24.10.2";
        target = "x86/64";
        arch = "x86_64";
        hostname = "OpenWrt";
        ip = "192.168.9.1";
        kver = "6.6.93-1-1745ebad77278f5cdc8330d17a3f43d6";
        service_ip = "192.168.9.23";
      };
      ax3600 = import ./wireless-ap {
        inherit lib inputs;
        release = "24.10.2";
        target = "qualcommax/ipq807x";
        arch = "aarch64_cortex-a53";
        hostname = "AX3600";
        ip = "192.168.9.11";
        kver = "6.6.93-1-8af96624c277fe1e57ffca5737140929";
      } // {
        uci.settings.wireless.wifi-device.radio0.path = "platform/soc@0/c000000.wifi+1";
        uci.settings.wireless.wifi-device.radio1.path = "platform/soc@0/c000000.wifi";
      };
    };
  };
}
