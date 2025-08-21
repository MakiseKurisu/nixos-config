{ config, lib, pkgs, inputs, options, ... }:

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
  '';
}
