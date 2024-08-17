{
  packages = [
    "luci-proto-modemmanager"
    "kmod-usb-net-qmi-wwan"
    "kmod-usb-serial-option"
    "uqmi"
  ];

  uci = {
    settings = {
      network = {
        interface = {
          wwan = {
            device = "/sys/devices/platform/1a0c0000.usb/usb1/1-1";
            proto = "modemmanager";
            apn = "CBNET";
            auth = "none";
            iptype = "ipv4v6";
            loglevel = "ERR";
          };
        };
      };
    };
  };
}
