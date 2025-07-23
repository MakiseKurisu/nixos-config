{ config, lib, pkgs, ... }:

{
  boot = {
    kernelParams = [
      "intel_iommu=on"
    ];
  };

  services.thermald.enable = lib.mkDefault true;
}
