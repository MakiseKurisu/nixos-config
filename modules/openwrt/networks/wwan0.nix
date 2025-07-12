{ lib
, ...}:
{
  packages = [
    "luci-proto-qmi"
    "kmod-usb-serial-option"
  ];

  etc = {
    "wwan/keep_alive".text = ''
      #!/usr/bin/env sh
      INTERFACE="$1"
      PARENT="''${2:-$1}"
      . /usr/share/libubox/jshn.sh
      json_load "$(ubus call "network.interface.$INTERFACE" status)"
      json_get_var up up
      if [ "$up" != "1" ]; then
        ifup "$PARENT"
      fi
    '';
    "wwan/lte_fallback".text = ''
      #!/usr/bin/env bash
      INTERFACE="$1"
      DEVICE="$2"
      . /usr/share/libubox/jshn.sh
      json_load "$(ubus call "network.interface.$INTERFACE" status)"
      json_get_var up up
      if [ "$up" != "1" ]; then
        logger -t "lte_fallback" "$INTERFACE is not up, skip"
        exit
      fi
      get_signal_info() {
        local signal_info="$(uqmi --device "$DEVICE" --get-signal-info)"
        type="$(grep type <<< "$signal_info" | cut -d '"' -f 4)"
        rsrp="$(grep rsrp <<< "$signal_info" | cut -d ' ' -f 2 | cut -d ',' -f 1)"
        rsrq="$(grep rsrq <<< "$signal_info" | cut -d ' ' -f 2 | cut -d ',' -f 1)"
        snr="$(grep snr <<< "$signal_info" | cut -d ' ' -f 2 | cut -d '.' -f 1)"
      }
      is_time_close() {
        get_signal_info
        time="$(date +%H%M)"
        [[ $type == "5gnr" ]] && [[ "$time" > "0058" ]] && [[ "$time" < "0102" ]]
      }
      is_5g_signal_bad() {
        get_signal_info
        if [[ $type != "5gnr" ]]; then
          return 1
        else
          (( rsrp < -80 )) && (( rsrq < -10 )) && (( snr < 15 ))
        fi
      }
      is_5g_station_on() {
        uqmi --device "$DEVICE" --get-cell-location-info | \
          grep -q -e '"physical_cell_id": 295' -e '"physical_cell_id": 296'
      }
      if is_time_close; then
        logger -t "lte_fallback" "time = $time, switching to LTE"
        uqmi --device "$DEVICE" --set-network-modes lte
        exit
      elif is_5g_station_on; then
        logger -t "lte_fallback" "cell 295/296 for channel 40936 is online, switching to default"
        uqmi --device "$DEVICE" --set-network-modes all
      fi
      if is_5g_signal_bad; then
        logger -t "lte_fallback" "rsrp = $rsrp, rsrq = $rsrq, snr = $snr, switching to LTE"
        uqmi --device "$DEVICE" --set-network-modes lte
      fi
    '';
    "crontabs/root".text = ''
      * * * * * sh /etc/wwan/keep_alive wwan0
      * * * * * sh /etc/wwan/keep_alive wwan0_4 wwan0
      * * * * * bash /etc/wwan/lte_fallback wwan0_4 /dev/cdc-wdm0
    '';
  };

  uci = {
    settings = {
      network = {
        interface = {
          wwan0 = {
            proto = "qmi";
            device = lib.mkDefault "/dev/cdc-wdm0";
            apn = "CBNET";
            auth = "none";
            pdptype = "ipv4v6";
            metric = 20;
            dns_metric = 20;
          };
        };
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "wwan0" "eth1" ];
}
