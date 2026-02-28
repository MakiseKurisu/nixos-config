{
  config,
  lib,
  pkgs,
  ...
}:

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
    systemPackages = with pkgs; [
      looking-glass-client
    ];
  };

  services = {
    udev.extraRules = ''
      SUBSYSTEM=="kvmfr", OWNER="excalibur", GROUP="libvirtd", MODE="0660"
    '';
  };

  virtualisation.libvirtd = {
    qemu = {
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

  home-manager.users.excalibur =
    { pkgs, ... }:
    {
      wayland.windowManager.hyprland = {
        settings = {
          exec-once = [
            "[workspace 1 silent] looking-glass-client"
          ];
        };
      };
    };
}
