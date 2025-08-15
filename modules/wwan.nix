{ config, lib, pkgs, inputs, options, ... }:

{
  services.udev.extraRules = ''
    # Restart openwrt instance, as new net device will not be auto reconnected
    ACTION=="move", SUBSYSTEM=="net", ENV{DEVTYPE}=="wwan", ENV{INTERFACE}=="wwan*", ENV{TAGS}==":systemd:", RUN+="${pkgs.writeShellScript "restart-openwrt" ''
      if ${lib.getExe config.virtualisation.incus.package} list -c s -f compact local:openwrt |
          ${lib.getExe pkgs.gnugrep} -q RUNNING; then
        ${lib.getExe' pkgs.util-linux "logger"} -s -t "restart-openwrt" "Detect wwan reconnection, but Incus instance is already running."
        ${lib.getExe config.virtualisation.incus.package} stop local:openwrt
      else
        ${lib.getExe' pkgs.util-linux "logger"} -s -t "restart-openwrt" "Detect wwan reconnection, and Incus instance is not running."
      fi
      ${lib.getExe config.virtualisation.incus.package} start local:openwrt
    ''}"

    # Attempt to recovery disconnected wwan device
    ACTION=="remove", SUBSYSTEM=="usbmisc", ENV{DEVNAME}=="/dev/cdc-wdm0", ENV{ID_MM_CANDIDATE}=="1", RUN+="${pkgs.writeShellScript "restart-machine" ''
      ${lib.getExe' pkgs.util-linux "logger"} -s -t "restart-machine" "Detect wwan disconnection."
      i=0
      while sleep 1; do
        i=$(( i + 1))
        if [[ -c /dev/cdc-wdm0 ]]; then
          ${lib.getExe' pkgs.util-linux "logger"} -s -t "restart-machine" "wwan reconnected in $i seconds."
          break
        fi
        if (( i >= 60 )); then
          ${lib.getExe' pkgs.util-linux "logger"} -s -t "restart-machine" "wwan did not recover in time. Trigger reboot."
          systemctl reboot
          break
        fi
      done
    ''}"
  '';

  systemd = {
    services = {
      qmi_wwan = {
        script = ''
          set -eu

          while read -r; do
            REPLY="$(cut -d ' ' -f 7 <<< "$REPLY" | sed -E "s/(.*)\:.*/\1/")"
            ${lib.getExe' pkgs.util-linux "logger"} -s -t "qmi_wwan" "Detect modem lock up."
            echo "$REPLY" > /sys/bus/usb/drivers/usb/unbind
            sleep 1
            echo "$REPLY" > /sys/bus/usb/drivers/usb/bind
          done < <(journalctl -kfS now --grep "qmi_wwan.*wwan.*: NETDEV WATCHDOG: CPU: .*: transmit queue .* timed out .* ms")
        '';
        wantedBy = [ "multi-user.target" ];
      };
    };

    network = {
      links = {
        "40-wwan0" = {
          matchConfig = {
            Type = "wwan";
            Property = "ID_SERIAL_SHORT=6f345e48";
          };
          linkConfig = {
            Name = "wwan10";
          };
        };
      };
    };
  };
}
