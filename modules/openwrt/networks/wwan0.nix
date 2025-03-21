# When OpenWrt is running from Incus, please add following configs:
#config:
#  raw.lxc: lxc.apparmor.profile=unconfined//&:incus-openwrt_<var-lib-incus>:unconfined
#devices:
#  wwan-cdc-wdm0:
#    mode: '0600'
#    path: /dev/cdc-wdm0
#    required: 'false'
#    type: unix-char
#  wwan:
#    nictype: physical
#    parent: wwp0s20u3i5
#    type: nic
#
# Related:
# https://discuss.linuxcontainers.org/t/unable-to-update-some-network-settings-when-apparmor-is-enabled/22109/3

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
    "wwan/query".text = ''
      #!/usr/bin/env sh
      set -x
      uqmi --device "$1" --get-current-settings
      uqmi --device "$1" --get-system-info
      uqmi --device "$1" --get-cell-location-info
      uqmi --device "$1" --get-tx-rx-info 5gnr
      uqmi --device "$1" --get-tx-rx-info lte
    '';
    "rc.local".text = ''
      bash -c "(( $(date +%H) >= 00 )) && (( $(date +%H) <= 07 )) && uqmi --device /dev/cdc-wdm0 --set-network-modes lte" &
    '';
    "crontabs/root".text = ''
      * * * * * sh /etc/wwan/keep_alive wwan0
      * * * * * sh /etc/wwan/keep_alive wwan0_4 wwan0
      1 1 * * * uqmi --device /dev/cdc-wdm0 --set-network-modes lte
      1 8 * * * uqmi --device /dev/cdc-wdm0 --set-network-modes all
      0 * * * * sh /etc/wwan/query /dev/cdc-wdm0 | logger -t wwan_query
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
          };
        };
      };
    };
  };
  services.statistics.monitors.interfaces.targets = [ "wwan0" "eth1" ];
}
