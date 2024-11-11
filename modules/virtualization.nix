{ config, lib, pkgs, ... }:

{
  boot = {
    initrd.kernelModules = [
      "vfio_pci"
      "vfio_iommu_type1"
    ];
    kernelParams = [
      "iommu=pt"
    ];
  };

  environment = {
    etc = {
      "looking-glass-client.ini" = {
        source = ../configs/looking-glass/looking-glass-client.ini;
        mode = "0644";
      };
    };
    systemPackages =
      with pkgs; [
        virt-manager
        wl-clipboard # used by waydroid
      ];
  };

  networking.firewall.allowedTCPPorts = [
    8443 # incus
  ];

  security.apparmor.enable = true;
  services.dbus.apparmor = "enabled";

  virtualisation = {
    lxc = {
      enable = true; # waydroid uses lxc
      defaultConfig = "lxc.include = ${pkgs.lxcfs}/share/lxc/config/common.conf.d/00-lxcfs.conf";
      lxcfs.enable = true;
    };
    incus = {
      enable = true;
      ui.enable = true;
      preseed = {
        config = {
          "core.https_address" = ":8443";
        };
      };
    };
    waydroid.enable = true;
  };
}
