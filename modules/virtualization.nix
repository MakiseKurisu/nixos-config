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
        wl-clipboard  # used by waydroid
      ];
  };

  virtualisation = {
    lxc.enable = true;  # waydroid uses lxc
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      qemu = {
        swtpm.enable = true;
        ovmf.packages = with pkgs; [
          unstable.OVMFFull.fd
        ];
      };
    };
    waydroid.enable = true;
  };
}
