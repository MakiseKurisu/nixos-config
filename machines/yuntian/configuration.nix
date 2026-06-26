{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ../../modules/zone/office.nix

    inputs.home-manager.nixosModules.home-manager
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/desktop-autostart.nix
    ../../modules/podman.nix
    # ../../modules/amd.nix
    ../../modules/intel.nix
    ../../modules/kernel.nix
    ../../modules/network.nix
    # ../../modules/nvidia.nix
    ../../modules/packages.nix
    ../../modules/users.nix
    ../../modules/vfio.nix
    ../../modules/virtualization.nix
    # ../../modules/impermanence.nix

    # ../../modules/nfs-nas.nix
    # ../../modules/nfs-app01.nix
    #../../modules/wireguard.nix

    # ../../modules/thinkpad.nix

    inputs.disko.nixosModules.disko
    # ./disko.nix
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = lib.mkForce pkgs.unstable.linuxPackages_latest;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

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
  };

  services.btrfs.autoScrub.enable = false;

  home-manager.users.excalibur =
    { pkgs, ... }:
    {
      home = {
        sessionVariables = {
          DEBEMAIL = "dev@radxa.com";
          DEBFULLNAME = "Radxa Computer Co., Ltd";
          EMAIL = "yt@radxa.com";
        };
        stateVersion = "22.11";
      };
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
              WantedBy = [ "timers.target" ];
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
          "${pkgs.xrdb}/bin/xrdb -merge <${pkgs.writeText "Xresources" ''
            Xft.dpi: 144
          ''}"
        ];
        workspace = [
          "r[1-20], monitor:DP-1"
          "2, monitor:DP-1, default:yes"
          "30, monitor:DP-2, default:yes"
        ];
        xwayland = {
          force_zero_scaling = true;
        };
      };
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
          MACAddress = "8c:3b:4a:35:d4:c8";
        };
        linkConfig = {
          Name = "eth0";
        };
      };
      "40-eth1" = {
        matchConfig = {
          OriginalName = lib.mkForce "e*";
          MACAddress = "8c:3b:4a:35:d4:c9";
        };
        linkConfig = {
          Name = "eth1";
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
          LLDP = false;
          EmitLLDP = false;
          IPv6AcceptRA = false;
          IPv6SendRA = false;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-eth1" = {
        matchConfig.Name = "eth1";
        networkConfig = {
          Bridge = "br0";
          LinkLocalAddressing = false;
          DHCP = false;
          LLDP = false;
          EmitLLDP = false;
          IPv6AcceptRA = false;
          IPv6SendRA = false;
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
