{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot = {
    kernelParams = [
      "intel_iommu=on"
      "i915.enable_guc=3"
    ];
  };

  services.thermald.enable = lib.mkDefault true;
}
