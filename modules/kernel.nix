{ config, lib, pkgs, inputs, ... }:

{
  disabledModules = [ "system/boot/kernel.nix" ];
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/system/boot/kernel.nix"
  ];

  boot = {
    kernelPackages = lib.mkOverride 990 pkgs.unstable.linuxPackages;
    kernelModules = [ "tcp_bbr" ];
    kernel.sysctl = {
      "kernel.dmesg_restrict" = 1;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_keepalive_time" = 60;
      "net.ipv4.tcp_keepalive_intvl" = 10;
      "net.ipv4.tcp_keepalive_probes" = 6;
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.core.default_qdisc" = "cake";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.conf.all.rp_filter" = 2;
      "net.ipv4.conf.default.rp_filter" = 2;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "net.ipv4.icmp_echo_ignore_all" = 0;
      "net.ipv6.icmp.echo_ignore_all" = 0;
    };
    loader = {
      efi = {
        canTouchEfiVariables = lib.mkDefault true;
      };
      systemd-boot.enable = true;
    };
  };
}
