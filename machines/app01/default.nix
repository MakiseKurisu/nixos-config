{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/base.nix
    ../../modules/file-share.nix
    #../../modules/desktop.nix
    ../../modules/podman.nix
    ../../modules/intel-base.nix
    ../../modules/kernel.nix
    ../../modules/network.nix
    #../../modules/nvidia.nix
    ../../modules/packages-base.nix
    ../../modules/users-base.nix
    #../../modules/vfio.nix
    ../../modules/virtualization-base.nix
    ../../modules/impermanence.nix

    #../../modules/nfs-nas.nix
    # ../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    # ../../modules/pr/fastapi-dls.nix
    # ../../modules/pr/pico-rpa.nix

    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
  ];

  boot = {
    kernelModules = [
      "iptable_mangle"
      "ip6table_mangle"
    ];
    extraModulePackages = with config.boot.kernelPackages; [ r8125 ];
    blacklistedKernelModules = [ "r8169" ];
  };

  services = {
    btrfs.autoScrub.enable = true;

    udev.extraRules = ''
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

    thermald.enable = false;  # Disable on older Intel systems
  };

  systemd.services = {
    e1000e = {
      script = ''
        set -eu
        ${lib.getExe pkgs.ethtool} -K eno1 tso off
      '';
      serviceConfig = {
        Type = "oneshot";
      };
      wantedBy = [ "sys-subsystem-net-devices-eno1.device" ];
    };
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

  networking.interfaces.eno1.useDHCP = false;
  systemd.network = {
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
    netdevs = {
       "20-br0" = {
         netdevConfig = {
           Kind = "bridge";
           Name = "br0";
         };
        bridgeConfig = {
          STP = true;
          VLANFiltering = true;
        };
       };
    };
    networks = {
      "30-eno1" = {
        matchConfig.Name = "eno1";
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "enslaved";
        bridgeVLANs = [
          {
            PVID = 1;
            EgressUntagged = 1;
          }
          {
            VLAN = 10;
          }
          {
            VLAN = 20;
          }
          {
            VLAN = 30;
          }
        ];
      };
      "40-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          LinkLocalAddressing = false;
        };
        bridgeConfig = {};
        bridgeVLANs = [
          {
            PVID = 1;
            EgressUntagged = 1;
          }
          {
            VLAN = 10;
          }
          {
            VLAN = 20;
          }
          {
            VLAN = 30;
          }
        ];
        vlan = [
          "vlan20"
        ];
        linkConfig = {
          RequiredForOnline = false;
        };
      };
      "50-vlan20" = {
        matchConfig.Name = "vlan20";
        networkConfig = {
          DHCP = true;
          Domains = "protoducer.com vamrs.org";
          Address = "192.168.9.2/24";
        };
        linkConfig = {
          RequiredForOnline = false;
        };
      };
    };
  };

  networking.hostName = "app01";
  system.stateVersion = "25.05";
}
