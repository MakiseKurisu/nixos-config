{
  packages = [
    "luci-proto-modemmanager"
    "kmod-usb-net-qmi-wwan"
    "kmod-usb-serial-option"
    "uqmi"
  ];

  etc = {
    "rc.local".text = ''
      sh /etc/wwan/reload_driver
    '';
    "wwan/reload_driver" = ''
      #!/bin/sh
      if [ "$(grep Driver=qmi_wwan /sys/kernel/debug/usb/devices | wc -l)" != "1" ]; then
        rmmod option
        rmmod qmi_wwan
      fi
      modprobe option
      modprobe qmi_wwan

      # https://whrl.pl/Rgk1Lv
      echo 2dee 4d22 ff 2001 7d04 > /sys/bus/usb-serial/drivers/option1/new_id
      echo 2dee 4d22 >/sys/bus/usb/drivers/qmi_wwan/new_id
    '';
    "crontabs/root".text = ''
      * * * * * sh /etc/wwan/reload_driver
    '';
  }

  uci = {
    settings = {
      network = {
        interface = {
          wwan0 = {
            device = "/sys/devices/platform/11200000.usb/usb1/1-1";
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
  services.statistics.monitors.interfaces.targets = [ "wwan0" ];
}
