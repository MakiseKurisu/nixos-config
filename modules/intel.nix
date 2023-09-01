{ config, lib, pkgs, ... }:

{
  boot = {
    kernelParams = [
      "intel_iommu=on"
    ];
  };
  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };
}
