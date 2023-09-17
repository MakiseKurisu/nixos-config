{ config, lib, pkgs, ... }:

{
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      kvmfr
    ];
    kernelModules = [
      "kvmfr"
    ];
    blacklistedKernelModules = [ "nouveau" "nvidiafb" "nvidia" "nvidia-uvm" "nvidia-drm" "nvidia-modeset" "nvidia-gpu" ];
    extraModprobeConfig = ''
      options kvmfr static_size_mb=128
    '';
  };

  environment = {
    systemPackages =
      with pkgs; [
        unstable.looking-glass-client
      ];
  };

  services = {
    udev.extraRules = ''
      SUBSYSTEM=="kvmfr", OWNER="excalibur", GROUP="libvirtd", MODE="0660"
    '';
  };

  virtualisation.libvirtd.qemu.verbatimConfig = ''
    cgroup_device_acl = [
        "/dev/null", "/dev/full", "/dev/zero",
        "/dev/random", "/dev/urandom",
        "/dev/ptmx", "/dev/kvm",
        "/dev/kvmfr0"
    ]
  '';
}
