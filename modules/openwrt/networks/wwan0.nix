{
  packages = [
    "luci-proto-modemmanager"
    "kmod-usb-net-qmi-wwan"
    "kmod-usb-serial-option"
    "uqmi"
  ];

  etc = {
    "wwan/keep_alive".text = ''
      #!/usr/bin/env sh
      INTERFACE="$1"
      . /usr/share/libubox/jshn.sh
      json_load "$(ubus call "network.interface.$INTERFACE" status)"
      json_get_var up up
      if [ "$up" != "1" ]; then
        ifup "$INTERFACE"
      fi
    '';
    "crontabs/root".text = ''
      * * * * * sh /etc/wwan/keep_alive wwan0
    '';
  };

  uci = {
    settings = {
      network = {
        interface = {
          wwan0 = {
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
