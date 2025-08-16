{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/desktop-autostart.nix
    ../../modules/podman.nix
    ../../modules/intel.nix
    ../../modules/kernel.nix
    ../../modules/network.nix
    ../../modules/nvidia.nix
    ../../modules/packages.nix
    ../../modules/users.nix
    ../../modules/vfio.nix
    ../../modules/virtualization.nix

    # ../../modules/nfs-nas.nix
    # ../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    inputs.disko.nixosModules.disko
    # ./disko.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = lib.mkForce pkgs.unstable.linuxPackages_latest;

  hardware = {
    graphics = {
      extraPackages = with pkgs; [
        # OpenCL filter support on 12th gen or newer
        intel-compute-runtime
        # OpenCL filter support up to 11th gen
        # see: https://github.com/NixOS/nixpkgs/issues/356535
        # intel-compute-runtime-legacy1

        # VAAPI on 5th gen or newer. LIBVA_DRIVER_NAME=iHD
        intel-media-driver
        # VAAPI up to 4th gen. LIBVA_DRIVER_NAME=i965
        # intel-vaapi-driver

        # QSV on 11th gen or newer
        vpl-gpu-rt
        # QSV up to 11th gen
        # intel-media-sdk
      ];
    };
    nvidia = {
      open = false;
      prime = {
        intelBusId = "PCI:0@0:2:0";
        nvidiaBusId = "PCI:1@0:0:0";
      };
    };
  };

  home-manager.users.excalibur = { pkgs, ... }: {
    systemd.user = {
      services = {
        lock-session = {
          Unit = {
            Description = "Lock current graphical session";
          };
          Service = {
            Type = "oneshot";
            ExecStart = ''
              ${lib.getExe pkgs.bash} -c \
                "${lib.getExe' pkgs.systemd "loginctl"} lock-session \
                  $$(${lib.getExe' pkgs.systemd "loginctl"} list-sessions | \
                  ${lib.getExe pkgs.gnugrep} tty1 | \
                  ${lib.getExe pkgs.gnugrep} active | \
                  ${lib.getExe' pkgs.coreutils "tr"} -s ' ' | \
                  ${lib.getExe' pkgs.coreutils "cut"} -d ' ' -f 2)"
            '';
          };
        };
      };
      timers = {
        lock-session = {
          Unit = {
            Description = "Lock current graphical session at given time";
          };
          Install = {
            WantedBy = ["timers.target"];
          };
          Timer = {
            OnCalendar = [
              "*-*-* 09:30:00"
              "*-*-* 12:00:00"
              "*-*-* 19:00:00"
              "*-*-* 19:30:00"
              "*-*-* 20:30:00"
            ];
          };
        };
      };
    };
    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "${pkgs.xorg.xrdb}/bin/xrdb -merge <${pkgs.writeText "Xresources" ''
          Xft.dpi: 144
        ''}"
      ];
      monitor = [
        "DP-1, highres, 0x0, 1.5, vrr, 0"
        "HDMI-A-2, highres, auto-right, 1.5"
      ];
      workspace = [
        "2, monitor:DP-1, default:yes"
        "30, monitor:HDMI-A-2, default:yes"
      ];
      xwayland = {
        force_zero_scaling = true;
      };
    };
  };

  powerManagement = {
    powertop.enable = false;
    cpuFreqGovernor = "performance";
  };

  programs = {
    git = {
      config = {
        credential = {
          "https://github.com".username = "RadxaYuntian";
        };
        user = {
          name = "ZHANG Yuntian";
          email = "yt@radxa.com";
        };
      };
    };
  };

  networking.interfaces.eth0.useDHCP = false;
  # enable WoL causes interface to be configured with DHCP
  # networking.interfaces.eth0.wakeOnLan.enable = true;
  systemd.network = {
    links = {
      "40-eth0" = {
        matchConfig = {
          OriginalName = lib.mkForce "e*";
          MACAddress = "d8:5e:d3:a6:72:b5";
        };
        linkConfig = {
          Name = "eth0";
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
      "30-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          Bridge = "br0";
          LinkLocalAddressing = false;
          DHCP = false;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "50-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          DHCP = true;
          Domains = "vamrs.org protoducer.com";
          Address = "192.168.2.20/24";
        };
        linkConfig = {
          RequiredForOnline = false;
        };
      };
    };
  };

  networking.hostName = "yuntian";
  system.stateVersion = "25.05";
}
