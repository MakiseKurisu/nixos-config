{ config, lib, pkgs, ... }:

{
  boot = {
    kernelParams = [
      "intel_iommu=on"
    ];
  };
}
