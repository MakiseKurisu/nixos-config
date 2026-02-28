{
  config,
  lib,
  pkgs,
  inputs,
  options,
  ...
}:

{
  services.udev.extraRules = ''
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
  '';

  systemd = {
    services = {
      qmi_wwan = {
        script = ''
          set -eu

          while read -r; do
            REPLY="$(cut -d ' ' -f 7 <<< "$REPLY" | sed -E "s/(.*)\:.*/\1/")"
            ${lib.getExe' pkgs.util-linux "logger"} -s -t "qmi_wwan" "Detect modem lock up."
            if [[ -f /sys/bus/usb/devices/"$REPLY"/port/disable ]]; then
              echo "USB supports port power management. Try power cycling."
              CURRENT_PORT="$(realpath /sys/bus/usb/devices/"$REPLY"/port)"
              if [[ -L "$CURRENT_PORT"/peer ]]; then
                PEER_PORT="$CURRENT_PORT/peer"
              else
                PEER_PORT="$CURRENT_PORT"
              fi
              echo 1 > "$PEER_PORT/disable"
              echo 1 > "$CURRENT_PORT/disable"
              sleep 1
              echo 0 > "$CURRENT_PORT/disable"
              echo 0 > "$PEER_PORT/disable"
            else
              echo "USB does not support port power management. Try driver reloading."
              echo "$REPLY" > /sys/bus/usb/drivers/usb/unbind
              sleep 1
              echo "$REPLY" > /sys/bus/usb/drivers/usb/bind
            fi
          done < <(journalctl -kfS now --grep "qmi_wwan.*wwan.*: NETDEV WATCHDOG: CPU: .*: transmit queue .* timed out .* ms")
        '';
        wantedBy = [ "multi-user.target" ];
      };
    };

    network = {
      links = {
        # Quectel RG520N-CN
        "40-wwan10" = {
          matchConfig = {
            Type = "wwan";
            Property = "ID_SERIAL_SHORT=d088c176";
          };
          linkConfig = {
            Name = "wwan10";
          };
        };
        # MeiG SRM825L
        "40-wwan11" = {
          matchConfig = {
            Type = "wwan";
            Property = "ID_SERIAL_SHORT=6f345e48";
          };
          linkConfig = {
            Name = "wwan11";
          };
        };
      };
    };
  };
}
