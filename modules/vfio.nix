{ config, lib, pkgs, ... }:

{
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      kvmfr
    ];
    extraModprobeConfig = ''
      options kvmfr static_size_mb=128
    '';
    kernelModules = [
      "kvmfr"
    ];
  };

  environment = {
    systemPackages =
      with pkgs; [
        virt-manager
        virt-viewer
        looking-glass-client
      ];
  };

  services = {
    udev.extraRules = ''
      SUBSYSTEM=="kvmfr", OWNER="excalibur", GROUP="libvirtd", MODE="0660"
    '';
  };

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    qemu = {
      swtpm.enable = true;
      ovmf.packages = with pkgs; [
        OVMFFull.fd
      ];
      verbatimConfig = ''
        cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm",
            "/dev/kvmfr0"
        ]
      '';
    };
  };
}
