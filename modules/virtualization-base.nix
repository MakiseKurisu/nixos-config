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

  networking.firewall.allowedTCPPorts = [
    8443 # incus
  ];

  security.apparmor.enable = true;
  services.dbus.apparmor = "enabled";

  virtualisation = {
    incus = {
      enable = true;
      ui.enable = true;
      preseed = {
        config = {
          "core.https_address" = ":8443";
        };
      };
    };
  };
}
